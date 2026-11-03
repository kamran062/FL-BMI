# Purchase verification (premium)

One HTTPS function, `verifyPurchase`. The app sends a store receipt after a
purchase or restore; the function checks it **with Google Play / Apple** and
returns a signed entitlement (ES256 JWT). The app verifies the signature with
the public key it ships with, so premium cannot be faked by editing app data.

No user data is stored. Tokens are never logged.

## One-time setup

1. **Firebase project** (Blaze plan — Cloud Functions need billing; this
   function stays within the free tier at normal volumes).
   ```sh
   firebase login
   firebase use --add            # pick your project
   ```

2. **Entitlement signing key** (keep the private key secret):
   ```sh
   openssl ecparam -name prime256v1 -genkey -noout | \
     openssl pkcs8 -topk8 -nocrypt -out entitlement_private.pem
   openssl ec -in entitlement_private.pem -pubout -out entitlement_public.pem
   firebase functions:secrets:set ENTITLEMENT_PRIVATE_KEY < entitlement_private.pem
   ```
   Put the **public** key (single line, `\n` for newlines) in `.env.json`
   as `ENTITLEMENT_PUBLIC_KEY`.

3. **Google Play**: Play Console → Setup → API access → create a service
   account with *View financial data* + *Manage orders*. Download its JSON key:
   ```sh
   firebase functions:secrets:set PLAY_SERVICE_ACCOUNT < play-service-account.json
   ```

4. **App Store**: App Store Connect → Users and Access → Integrations →
   In-App Purchase key (.p8):
   ```sh
   firebase functions:secrets:set APPLE_PRIVATE_KEY < SubscriptionKey_XXXX.p8
   ```
   and set `APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `APPLE_BUNDLE_ID` when deploy asks.

5. **Deploy**, then put the function URL in `.env.json` as
   `PREMIUM_VERIFY_URL`:
   ```sh
   cd functions && npm install && npm test && npm run deploy
   ```

Premium stays hidden in the app until both `PREMIUM_VERIFY_URL` and
`ENTITLEMENT_PUBLIC_KEY` are set at build time.

## Tests

`npm test` — store responses are faked; covers active / grace / cancelled /
expired / on-hold subscriptions, lifetime, refunds, wrong product, bad input,
and signature tampering.
