'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const jose = require('jose');
const { verifyPurchase, BadRequest, LIFETIME_EXPIRY } = require('../src/verify');
const { signEntitlement } = require('../src/entitlement');

const NOW = Date.UTC(2026, 10, 4);
const DAY = 24 * 3600 * 1000;
const TOKEN = 'purchase-token-123';

const google = (sub, prod) => ({
  google: { subscription: async () => sub, product: async () => prod },
});
const apple = (t) => ({ apple: { transaction: async () => t } });

test('android: active subscription', async () => {
  const r = await verifyPurchase(
    { platform: 'android', productId: 'bmi_health_premium_monthly', token: TOKEN },
    google({
      subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
      lineItems: [{ productId: 'bmi_health_premium_monthly',
        expiryTime: new Date(NOW + 20 * DAY).toISOString() }],
    }), NOW);
  assert.equal(r.active, true);
  assert.equal(r.expiresAt, NOW + 20 * DAY);
});

test('android: cancelled but paid until later still has access', async () => {
  const r = await verifyPurchase(
    { platform: 'android', productId: 'bmi_health_premium_yearly', token: TOKEN },
    google({
      subscriptionState: 'SUBSCRIPTION_STATE_CANCELED',
      lineItems: [{ productId: 'bmi_health_premium_yearly',
        expiryTime: new Date(NOW + 5 * DAY).toISOString() }],
    }), NOW);
  assert.equal(r.active, true);
});

test('android: expired or on hold has no access', async () => {
  for (const [state, exp] of [
    ['SUBSCRIPTION_STATE_EXPIRED', NOW - DAY],
    ['SUBSCRIPTION_STATE_ON_HOLD', NOW + DAY],
    ['SUBSCRIPTION_STATE_ACTIVE', NOW - DAY],
  ]) {
    const r = await verifyPurchase(
      { platform: 'android', productId: 'bmi_health_premium_monthly', token: TOKEN },
      google({ subscriptionState: state, lineItems: [{
        productId: 'bmi_health_premium_monthly', expiryTime: new Date(exp).toISOString() }] }),
      NOW);
    assert.equal(r.active, false, state);
  }
});

test('android: token for a different product is rejected', async () => {
  const r = await verifyPurchase(
    { platform: 'android', productId: 'bmi_health_premium_yearly', token: TOKEN },
    google({ subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
      lineItems: [{ productId: 'bmi_health_premium_monthly',
        expiryTime: new Date(NOW + DAY).toISOString() }] }), NOW);
  assert.equal(r.active, false);
});

test('android: lifetime purchased vs pending', async () => {
  const ok = await verifyPurchase(
    { platform: 'android', productId: 'bmi_health_premium_lifetime', token: TOKEN },
    google(null, { purchaseState: 0 }), NOW);
  assert.equal(ok.active, true);
  assert.equal(ok.expiresAt, LIFETIME_EXPIRY);
  const pending = await verifyPurchase(
    { platform: 'android', productId: 'bmi_health_premium_lifetime', token: TOKEN },
    google(null, { purchaseState: 2 }), NOW);
  assert.equal(pending.active, false);
});

test('ios: active, expired and refunded', async () => {
  const req = { platform: 'ios', productId: 'bmi_health_premium_monthly', token: '2000000123456789' };
  assert.equal((await verifyPurchase(req, apple({
    productId: req.productId, expiresDate: NOW + DAY }), NOW)).active, true);
  assert.equal((await verifyPurchase(req, apple({
    productId: req.productId, expiresDate: NOW - DAY }), NOW)).active, false);
  assert.equal((await verifyPurchase(req, apple({
    productId: req.productId, expiresDate: NOW + DAY, revocationDate: NOW }), NOW)).active, false);
});

test('bad input is a 400, not a store call', async () => {
  const boom = { google: { subscription: () => assert.fail('called') } };
  await assert.rejects(verifyPurchase({ platform: 'android', productId: 'free_stuff', token: TOKEN }, boom), BadRequest);
  await assert.rejects(verifyPurchase({ platform: 'android', productId: 'bmi_health_premium_monthly', token: 'x' }, boom), BadRequest);
  await assert.rejects(verifyPurchase({ platform: 'web', productId: 'bmi_health_premium_monthly', token: TOKEN }, boom), BadRequest);
});

test('entitlement is signed, verifiable with the public key, and capped at 35 days', async () => {
  const { privateKey, publicKey } = crypto.generateKeyPairSync('ec', { namedCurve: 'P-256' });
  const pem = privateKey.export({ type: 'pkcs8', format: 'pem' });
  const jwt = await signEntitlement(
    { active: true, productId: 'bmi_health_premium_yearly', expiresAt: NOW + 300 * DAY },
    pem, NOW);
  const { payload } = await jose.jwtVerify(jwt, publicKey, { currentDate: new Date(NOW) });
  assert.equal(payload.active, true);
  assert.equal(payload.exp, Math.floor((NOW + 35 * DAY) / 1000));

  // Tampering breaks the signature
  const [h, p, s] = jwt.split('.');
  const forged = Buffer.from(JSON.stringify({ ...payload, productId: 'x' })).toString('base64url');
  await assert.rejects(jose.jwtVerify(`${h}.${forged}.${s}`, publicKey));
});
