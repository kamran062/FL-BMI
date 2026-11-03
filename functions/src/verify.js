'use strict';

// Product IDs — must match Play Console / App Store Connect and
// lib/features/premium/purchase_service.dart.
const SUBSCRIPTIONS = new Set(['bmi_health_premium_monthly', 'bmi_health_premium_yearly']);
const LIFETIME = 'bmi_health_premium_lifetime';
const KNOWN = new Set([...SUBSCRIPTIONS, LIFETIME]);

// Lifetime purchases get a far-future expiry so the app logic stays simple.
const LIFETIME_EXPIRY = Date.UTC(2100, 0, 1);

/** Thrown for bad input (→ HTTP 400). */
class BadRequest extends Error {}

/**
 * Checks a purchase with the store and returns the entitlement.
 *
 * @param {object} req  { platform: 'android'|'ios', productId, token }
 *   android: token = purchaseToken; ios: token = transactionId
 * @param {object} stores injected store clients (real or fakes in tests):
 *   google.subscription(token) → Play SubscriptionPurchaseV2
 *   google.product(productId, token) → Play ProductPurchase
 *   apple.transaction(transactionId) → decoded JWSTransactionDecodedPayload
 * @param {number} now ms since epoch
 * @returns {Promise<{active: boolean, productId: string, expiresAt: number}>}
 */
async function verifyPurchase(req, stores, now = Date.now()) {
  const { platform, productId, token } = req || {};
  if (!KNOWN.has(productId)) throw new BadRequest('unknown product');
  if (typeof token !== 'string' || token.length < 8 || token.length > 4096) {
    throw new BadRequest('bad token');
  }

  if (platform === 'android') {
    if (productId === LIFETIME) {
      const p = await stores.google.product(productId, token);
      // purchaseState: 0 purchased, 1 cancelled, 2 pending
      const ok = p && p.purchaseState === 0;
      return { active: ok, productId, expiresAt: ok ? LIFETIME_EXPIRY : 0 };
    }
    const s = await stores.google.subscription(token);
    const line = (s && s.lineItems || []).find((l) => l.productId === productId);
    if (!line) return { active: false, productId, expiresAt: 0 };
    const expiresAt = Date.parse(line.expiryTime) || 0;
    // Grace period and cancelled-but-not-yet-expired still have access.
    const states = new Set([
      'SUBSCRIPTION_STATE_ACTIVE',
      'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
      'SUBSCRIPTION_STATE_CANCELED',
    ]);
    const active = states.has(s.subscriptionState) && expiresAt > now;
    return { active, productId, expiresAt: active ? expiresAt : 0 };
  }

  if (platform === 'ios') {
    const t = await stores.apple.transaction(token);
    if (!t || t.productId !== productId || t.revocationDate) {
      return { active: false, productId, expiresAt: 0 };
    }
    if (productId === LIFETIME) {
      return { active: true, productId, expiresAt: LIFETIME_EXPIRY };
    }
    const expiresAt = Number(t.expiresDate) || 0;
    const active = expiresAt > now;
    return { active, productId, expiresAt: active ? expiresAt : 0 };
  }

  throw new BadRequest('unknown platform');
}

module.exports = { verifyPurchase, BadRequest, KNOWN, LIFETIME, LIFETIME_EXPIRY };
