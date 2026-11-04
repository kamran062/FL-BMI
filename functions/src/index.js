'use strict';

// HTTPS endpoint the app calls after a purchase or restore:
//   POST { platform, productId, token }  →  { entitlement: <signed JWT> }
//
// Setup (once, on your Firebase project — see functions/README.md):
//   firebase functions:secrets:set ENTITLEMENT_PRIVATE_KEY   (ES256 PKCS#8 PEM)
//   firebase functions:secrets:set PLAY_SERVICE_ACCOUNT      (JSON key)
//   firebase functions:secrets:set APPLE_PRIVATE_KEY         (App Store Connect .p8)
//   + params APPLE_KEY_ID, APPLE_ISSUER_ID, APPLE_BUNDLE_ID, ANDROID_PACKAGE

const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret, defineString } = require('firebase-functions/params');
const { verifyPurchase, BadRequest } = require('./verify');
const { signEntitlement } = require('./entitlement');

const ENTITLEMENT_PRIVATE_KEY = defineSecret('ENTITLEMENT_PRIVATE_KEY');
const PLAY_SERVICE_ACCOUNT = defineSecret('PLAY_SERVICE_ACCOUNT');
const APPLE_PRIVATE_KEY = defineSecret('APPLE_PRIVATE_KEY');
const APPLE_KEY_ID = defineString('APPLE_KEY_ID', { default: '' });
const APPLE_ISSUER_ID = defineString('APPLE_ISSUER_ID', { default: '' });
const APPLE_BUNDLE_ID = defineString('APPLE_BUNDLE_ID', { default: '' });
const ANDROID_PACKAGE = defineString('ANDROID_PACKAGE', { default: 'com.bmihealth.bmi_health' });

function googleStore() {
  const { google } = require('googleapis');
  const auth = new google.auth.GoogleAuth({
    credentials: JSON.parse(PLAY_SERVICE_ACCOUNT.value()),
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  const api = google.androidpublisher({ version: 'v3', auth });
  const packageName = ANDROID_PACKAGE.value();
  return {
    subscription: async (token) =>
      (await api.purchases.subscriptionsv2.get({ packageName, token })).data,
    product: async (productId, token) =>
      (await api.purchases.products.get({ packageName, productId, token })).data,
  };
}

function appleStore() {
  const {
    AppStoreServerAPIClient, Environment, SignedDataVerifier,
  } = require('@apple/app-store-server-library');
  const bundleId = APPLE_BUNDLE_ID.value();
  const client = (env) => new AppStoreServerAPIClient(
    APPLE_PRIVATE_KEY.value(), APPLE_KEY_ID.value(), APPLE_ISSUER_ID.value(),
    bundleId, env);
  return {
    // Try production, fall back to sandbox (TestFlight / review builds).
    transaction: async (id) => {
      for (const env of [Environment.PRODUCTION, Environment.SANDBOX]) {
        try {
          const res = await client(env).getTransactionInfo(id);
          // Apple's root certificates are fetched by the library; signature
          // verification of the JWS is enforced here.
          const verifier = new SignedDataVerifier([], true, env, bundleId);
          return await verifier.verifyAndDecodeTransaction(res.signedTransactionInfo);
        } catch (e) {
          if (env === Environment.SANDBOX) throw e;
        }
      }
      return null;
    },
  };
}

exports.verifyPurchase = onRequest(
  {
    region: 'us-central1',
    secrets: [ENTITLEMENT_PRIVATE_KEY, PLAY_SERVICE_ACCOUNT, APPLE_PRIVATE_KEY],
    maxInstances: 10,
    cors: false,
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('POST only');
      return;
    }
    try {
      const body = req.body || {};
      const stores = {
        google: body.platform === 'android' ? googleStore() : null,
        apple: body.platform === 'ios' ? appleStore() : null,
      };
      const ent = await verifyPurchase(body, stores);
      const entitlement = await signEntitlement(ent, ENTITLEMENT_PRIVATE_KEY.value());
      res.json({ entitlement });
    } catch (e) {
      if (e instanceof BadRequest) {
        res.status(400).json({ error: e.message });
      } else {
        // Never log tokens; they identify a purchase.
        console.error('verifyPurchase failed:', e && e.message);
        res.status(502).json({ error: 'store_unavailable' });
      }
    }
  },
);

// ── AI coach & food-photo estimate ──────────────────────────────────────────
//   firebase functions:secrets:set ANTHROPIC_API_KEY
// Daily per-install usage counters live in Firestore (collection ai_usage);
// documents hold only a count — no messages or photos are stored.

const ANTHROPIC_API_KEY = defineSecret('ANTHROPIC_API_KEY');
const ai = require('./ai');

let _admin;
function firestoreStore() {
  if (!_admin) {
    _admin = require('firebase-admin');
    if (!_admin.apps.length) _admin.initializeApp();
  }
  const db = _admin.firestore();
  return {
    increment: (key) => db.runTransaction(async (tx) => {
      const ref = db.collection('ai_usage').doc(key);
      const snap = await tx.get(ref);
      const count = (snap.exists ? snap.get('count') : 0) + 1;
      // expireAt lets a Firestore TTL policy delete old counters.
      tx.set(ref, { count, expireAt: new Date(Date.now() + 3 * 864e5) });
      return count;
    }),
  };
}

function aiEndpoint(handler) {
  return onRequest(
    { region: 'us-central1', secrets: [ANTHROPIC_API_KEY], maxInstances: 10, timeoutSeconds: 120, cors: false },
    async (req, res) => {
      if (req.method !== 'POST') {
        res.status(405).send('POST only');
        return;
      }
      try {
        const Anthropic = require('@anthropic-ai/sdk');
        const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
        res.json(await handler(req.body, { client, store: firestoreStore(), now: new Date() }));
      } catch (e) {
        if (e instanceof ai.BadRequest) {
          res.status(400).json({ error: e.message });
        } else if (e instanceof ai.RateLimited) {
          res.status(429).json({ error: 'daily_limit' });
        } else {
          // Never log message text or images.
          console.error('ai endpoint failed:', e && e.constructor && e.constructor.name, e && e.status);
          res.status(502).json({ error: 'unavailable' });
        }
      }
    },
  );
}

exports.coach = aiEndpoint(ai.coach);
exports.estimateFood = aiEndpoint(ai.estimateFood);
