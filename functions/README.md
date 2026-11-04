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

# AI coach and food-photo estimate

Two more HTTPS functions, `coach` and `estimateFood`, call Claude
(`claude-opus-5-5`) with your Anthropic API key, which stays on the server.

1. Get an API key at console.anthropic.com and set it:
   ```sh
   firebase functions:secrets:set ANTHROPIC_API_KEY
   ```
2. Enable Firestore (native mode). Usage counters go in `ai_usage`; add a
   TTL policy on the `expireAt` field so old counters delete themselves.
3. Deploy, then put the two URLs in `.env.json` as `COACH_URL` and
   `FOOD_PHOTO_URL`. The features stay hidden in the app until set.

Limits: 30 coach messages and 15 photo estimates per install per day
(`LIMITS` in `src/ai.js`). Emergencies get a fixed reply without an API call.
Nothing the user sends is stored or logged.

**Cost:** set a monthly spend limit in the Anthropic Console before launch.
Before scaling, add Firebase App Check so only your app can call these URLs.
