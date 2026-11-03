'use strict';

const jose = require('jose');

/**
 * Signs the entitlement so the app can trust it offline.
 * ES256 (P-256); the app ships only the public key.
 * The token expires with the subscription (capped at 35 days so the app
 * re-checks renewals/refunds at least monthly).
 */
async function signEntitlement(ent, privateKeyPem, now = Date.now()) {
  const key = await jose.importPKCS8(privateKeyPem, 'ES256');
  const cap = now + 35 * 24 * 3600 * 1000;
  const exp = Math.floor(Math.min(ent.expiresAt || now, cap) / 1000);
  return new jose.SignJWT({
    active: ent.active,
    productId: ent.productId,
    expiresAt: ent.expiresAt,
  })
    .setProtectedHeader({ alg: 'ES256' })
    .setIssuer('bmi-health')
    .setIssuedAt(Math.floor(now / 1000))
    .setExpirationTime(exp)
    .sign(key);
}

module.exports = { signEntitlement };
