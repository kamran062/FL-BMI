# Store privacy answers

How to fill in **Google Play → Data safety** and **App Store Connect → App
Privacy** for BMI Health. Based on what the code sends off the device as of
this release. Re-check it whenever a feature that talks to a server changes.

**Key rule both stores use:** data that is processed only on the phone and
never sent off it is *not* "collected". Most of this app's health data falls
under that rule.

## Stays on the device (not "collected")

| Data | Where it lives |
|---|---|
| Weight, BMI, body measurements | Local database |
| Workouts, sets, programs, rep-counter results | Local database |
| Food and water logs | Local database |
| Steps, sleep, resting heart rate, HRV (read from Health Connect / Apple Health) | Read on the phone, never uploaded |
| Location history, places, gym visits | Local database |
| Cycle data | Local database (opt-in, can be locked and deleted) |
| Progress photos | Encrypted files in app storage |
| Camera frames (rep counter, barcode) | Analysed in memory, never saved |
| Watch heart rate / set taps | Phone ↔ own watch only |

Cloud backup and device transfer are switched off (Android) / excluded
(iOS). The user's own encrypted backup file is created by them and stored
where they choose; we cannot read it, so it is not collection either.

## Sent off the device

| Data type (store wording) | Sent to | When | Purpose | Optional? | Ephemeral? |
|---|---|---|---|---|---|
| **Device or other IDs** (advertising ID) | Google AdMob | Ads shown (free users) | Advertising | Yes — consent (UMP / ATT) | No |
| **Approximate location** (from IP) | Google AdMob | Ads shown | Advertising | Yes — consent | No |
| **App interactions, diagnostics** | Google AdMob | Ads shown | Advertising, fraud prevention | Yes — consent | No |
| **Crash logs, diagnostics** | Sentry | Only if `SENTRY_DSN` is set | App functionality (crash fixing) | No | No |
| **Purchase history** (purchase token, product) | Our verification server → Google / Apple | Buying / restoring premium | App functionality | Yes | **Yes** (nothing stored) |
| **Other user-generated content** (coach questions) | Our server → Anthropic | Using the AI coach | App functionality | Yes, with consent screen | **Yes** |
| **Photos** (meal photo) | Our server → Anthropic | Photo calorie estimate | App functionality | Yes, with consent screen | **Yes** |
| **Health info / fitness info** (age, sex, weight, goal, experience, training days) | Our server → Anthropic | With each coach question | App functionality (personalised answers) | Yes, with consent screen | **Yes** |
| Barcode number | Open Food Facts | Scanning a product | App functionality | Yes | — (not personal data) |
| Map area being viewed | OpenStreetMap tile server | Opening the timeline map | App functionality | Yes | See note |

Notes:
- **Sharing vs collection (Play):** Anthropic, Sentry and the stores act as
  service providers processing on our behalf, so mark these as *collected*,
  not *shared*. **AdMob is collection by a third-party SDK for advertising** —
  mark the advertising ID as *collected* and *shared* (Play) / *Used to
  Track You* (Apple), unless ads run only in non-personalised mode.
- **Map tiles:** tile requests reveal which area is on screen (like any map).
  Conservative answer: *Approximate location — collected, ephemeral, app
  functionality*. Switching to a paid tile provider under a DPA doesn't
  change this answer.
- **Encryption in transit:** yes — every request uses HTTPS.
- **Deletion:** users can delete all data in the app (uninstalling removes
  it; cycle data and location history have their own delete buttons). Our
  servers store nothing, so there is nothing to request deletion of —
  answer *"Yes, users can request deletion"* and point to the privacy policy.
- **Account:** none. No sign-in, no name, no email.

## Apple App Privacy (summary)

- **Data Used to Track You:** Device ID (only when the user allows tracking
  in the ATT prompt; otherwise ads are non-personalised).
- **Data Linked to You:** none (no accounts).
- **Data Not Linked to You:** Coarse location, Product interaction,
  Advertising data (AdMob); Crash data, Performance data (Sentry, if
  enabled); Purchase history (verification); Health & Fitness, Photos,
  Other user content (AI features, only when used).

## Health-specific declarations

- **Play — Health apps declaration:** fitness / wellness app; not a medical
  device; disclaimer shown in app ("For general wellness only. Not medical
  advice.") and must also be in the store description.
- **Play — Health Connect:** read-only Steps, Sleep, Resting heart rate,
  HRV. Justification: daily steps card and recovery score.
- **Play — Foreground service (location):** "Tracks the user's day to
  build a private movement timeline, started by the user, with a visible
  notification." No background location permission is requested.
- **Apple — HealthKit:** read steps, sleep, resting HR, HRV (iPhone);
  heart rate during workouts (Apple Watch, workout session discarded —
  nothing written).
