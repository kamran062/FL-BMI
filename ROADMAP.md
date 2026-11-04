# BMI Health → Health & Gym App — Product Roadmap

> **Status:** Draft v1 · **Owner:** Kamran Iqbal · **Last updated:** 2026-11-01
>
> This roadmap turns the existing BMI Calculator & Health app into a full health
> and gym app. The current BMI calculator stays and becomes one module inside the
> **Body** section. Every module below follows the same production standard:
> scope → technical design → development checklist → testing → definition of done.

---

## Table of contents

1. [Product vision](#1-product-vision)
2. [App structure](#2-app-structure)
3. [Gender-specific experience](#3-gender-specific-experience)
4. [Human exercise video & animation standard](#4-human-exercise-video--animation-standard)
5. [Production standards (apply to every module)](#5-production-standards-apply-to-every-module)
6. [Phase 0 — Foundation & release blockers](#phase-0--foundation--release-blockers)
7. [Phase 1 — Core health & gym MVP](#phase-1--core-health--gym-mvp)
8. [Phase 2 — Movement & daily life tracking](#phase-2--movement--daily-life-tracking)
9. [Phase 3 — Smart training & premium launch](#phase-3--smart-training--premium-launch)
10. [Phase 4 — Health intelligence](#phase-4--health-intelligence)
11. [Phase 5 — Engagement, sync & wearables](#phase-5--engagement-sync--wearables)
12. [Store compliance checklist](#12-store-compliance-checklist)
13. [Risks & mitigations](#13-risks--mitigations)
14. [Timeline summary](#14-timeline-summary)

---

## 1. Product vision

**One app that knows your body, trains you like a real coach, and understands your day.**

Three signature features set the app apart from typical gym loggers:

| Signature feature | Why it is unique |
|---|---|
| **Movement timeline** | Shows where the user went, the route they took, how long they stayed at each place, and steps and calories for the whole day. |
| **Automatic gym check-in** | Detects arrival at the user's gym, offers to start the workout, and logs time spent there. Links the timeline to the workout tracker. |
| **Human-coached workouts** | Real human exercise videos with the demonstrator's gender matched to the user's profile, plus a camera rep counter that checks form. |

**Principles**
- **Private by default:** health, location and body data stay on the device unless the user turns on backup.
- **Opt-in for sensitive features:** location, camera, cycle tracking and health sync are all off until the user turns them on.
- **Battery is a feature:** any background work has a measured battery budget.
- **Not medical advice:** the app gives guidance and shows clear disclaimers. It never diagnoses.

---

## 2. App structure

### Bottom navigation (5 tabs)

| Tab | Contents |
|---|---|
| **Today** | Today's workout, steps ring, water, weight check-in, timeline preview, streaks, recovery score |
| **Train** | Workout logger, routines, programs, exercise library (human videos), camera rep counter, PRs |
| **Body** | Weight trend, measurements, **BMI module (existing app)**, body fat, progress photos, cycle tracking (opt-in) |
| **Fuel** | Calorie & macro targets, water, meal log, barcode scanner, food photo estimate |
| **Profile** | Personal details (incl. gender), goals, units, places (home/gym/work), reminders, premium, privacy, settings |

### Code architecture (target)

```
lib/
  app/                 # app shell, router (go_router), DI, theme bootstrap
  core/                # database, migrations, logging, analytics, permissions, errors
  shared/              # design system: theme, colors, widgets (existing lib/widgets moves here)
  features/
    profile/           # profile, onboarding, gender & demonstrator preference
    today/
    body/
      bmi/             # ← existing BMI calculator, history, goal, share, tips
      weight/
      measurements/
      photos/
      cycle/
    train/
      exercises/
      workouts/
      programs/
      rep_counter/
    fuel/
    movement/          # steps, timeline, places, activity detection, geofence
    recovery/
    coach/
    premium/           # existing purchase_service + paywall
    ads/               # existing ad_service + banner widget
  l10n/                # English + Urdu
```

Each feature has `data/` (repositories, DAOs), `domain/` (models, pure logic), and `ui/` (screens, widgets, state).

---

## 3. Gender-specific experience

The app's flow adapts to the **gender stored in the user's profile** (`UserProfile.gender`: `m` / `f` / `o`).
The user can change it, or override individual parts, at any time from **Profile → Personal details**.

### What gender controls

| Area | Male (`m`) | Female (`f`) | Other / prefer not to say (`o`) |
|---|---|---|---|
| **Exercise demonstrator** | Male demonstrator videos | Female demonstrator videos | User picks a demonstrator during onboarding |
| **BMR / calorie formula** | Mifflin-St Jeor (male constant) | Mifflin-St Jeor (female constant) | User picks a formula basis; the app explains why it is needed |
| **Body-fat (US Navy method)** | Neck + waist | Neck + waist + **hips** | Uses the basis the user chose |
| **Measurement fields** | Chest, arms, waist, neck, thighs | Bust, waist, **hips**, arms, thighs, neck | All fields available |
| **Onboarding program suggestions** | Shows the most-chosen goals first (e.g. muscle gain, strength) | Shows the most-chosen goals first (e.g. toning, glutes and lower body, fat loss) | Neutral list |
| **Cycle tracking & cycle-aware training** | Hidden | Offered (opt-in) | Offered (opt-in) |
| **Illustrations, avatars, muscle heatmap body** | Male body model | Female body model | User's chosen model |
| **Tips & articles** | Shared plus male-relevant content | Shared plus female-relevant content (pregnancy and postpartum safety notes, cycle, bone health) | Shared content |

### Rules
- Gender changes **suggestions and visuals only**. Every program, exercise and feature is available to everyone.
- A separate **"Demonstrator preference"** setting (`auto` / `male` / `female`) lets anyone override the video demonstrator. `auto` follows the profile gender.
- Never use gender in ad targeting or analytics events.

### Data model change
```dart
// UserProfile additions
final String demonstratorPref;   // 'auto' | 'male' | 'female'
final String formulaBasis;       // 'male' | 'female' (only asked when gender == 'o')
final bool cycleTrackingEnabled; // default false
```

---

## 4. Human exercise video & animation standard

Gym content must look and feel like **a real person training**, not a cartoon or a stiff 3D robot.

### Content approach (recommended order)

1. **Filmed real human demonstrators (primary).** Hire male and female trainers and film every exercise. This looks the most natural and is what users trust.
2. **Licensed stock exercise footage (to fill gaps quickly).** Check that the licence allows use in a commercial app, both genders, and offline caching.
3. **Realistic 3D motion-capture avatars (secondary).** Use only for the muscle-highlight overlay and slow-motion form breakdowns. Motion must come from real motion capture, not keyframed animation.
4. **AI-generated video:** **not recommended for form demos.** Current models still produce wrong joint angles and inconsistent bodies, and showing wrong form can cause injuries.

### Filming specification

| Item | Standard |
|---|---|
| Demonstrators | At least 1 male and 1 female trainer, certified. Ideally several body types and ages. |
| Coverage | Every exercise filmed by **both** a male and a female demonstrator |
| Angles | Front + side (45° for complex lifts) |
| Clip types | (a) 6–10 s seamless loop for the workout screen, (b) 30–60 s full tutorial with voice cues, (c) common-mistake clip |
| Source quality | 4K 30/60 fps, stable tripod, consistent gym set and lighting |
| Delivery | HLS adaptive streaming at 1080p / 720p / 480p, plus a 720p loop for offline cache |
| Attire | Plain gym wear, no brand logos (avoids trademark issues) |
| Audio | Voiceover in English and Urdu, plus subtitles |
| Legal | Signed model release from every demonstrator and a written licence for every clip |
| Accessibility | Captions on all tutorial videos; written step-by-step instructions alongside every video |

### Humanised feel in the app
- **Natural tempo:** play loops at real speed by default, with a 0.5× slow-motion option for form.
- **Breathing and effort cues:** voice prompts such as "breathe out as you push" and on-screen tempo counts (e.g. 3-1-1).
- **Rest-screen coach:** between sets, show a short clip of the demonstrator resting and stretching, with a countdown.
- **Muscle highlight overlay:** a semi-transparent highlight of the target muscles on the paused frame.
- **Rep sync:** during a set, the video loop matches the user's rep count from the camera rep counter, when it's on.

### Content pipeline
```
Film → edit → colour grade → export masters → transcode (HLS + loop MP4)
     → upload to CDN (versioned paths) → update exercise catalog JSON (CMS)
     → app downloads catalog → streams or caches videos on demand
```
- Videos are **not bundled in the app**. The app ships only the catalog plus thumbnails for the top 30 exercises, to keep install size small.
- **Catalog versioning:** `catalog_v{n}.json` with `exerciseId`, `name` (en/ur), `muscles`, `equipment`, `difficulty`, `videos: { male: {...}, female: {...} }`, `instructions`, `mistakes`.

### Initial content scope
- **Launch (Phase 1):** top 100 exercises × 2 genders = **200 loop clips + 200 tutorials**
- **Phase 3:** grow to 300 exercises, including home and no-equipment variants

---

## 5. Production standards (apply to every module)

Every module in this roadmap is only "done" when it meets all of these.

### 5.1 Development
- [ ] Feature-folder structure (`data` / `domain` / `ui`), no business logic in widgets
- [ ] Typed models with `fromMap`/`toMap` tested in both directions
- [ ] Database schema change goes through a **numbered migration**, tested from every previous version
- [ ] All user-facing strings in `l10n` (English + Urdu), no hard-coded text
- [ ] Light and dark mode both designed and checked
- [ ] Empty, loading and error states for every screen
- [ ] Permissions requested **in context** with an explanation screen first; denial handled cleanly
- [ ] Analytics events defined (no health values, no location, no gender in event payloads)
- [ ] Feature flag (remote or local) so the module can be switched off without a release
- [ ] `flutter analyze` shows zero warnings; code formatted

### 5.2 Testing

| Layer | Tool | Target |
|---|---|---|
| Unit tests (logic, calculators, repositories) | `flutter_test` | **≥ 90 %** coverage of `domain/` |
| Widget tests (screens, states) | `flutter_test` | Every screen: empty, loaded and error states |
| Golden tests (design system, key screens) | `golden_toolkit` / `alchemist` | Light + dark, small + large phone |
| Database migration tests | `sqflite_common_ffi` | Upgrade from every past schema version |
| Integration tests (real flows, permissions) | `integration_test` + **Patrol** | Main happy path + permission denial path |
| Device matrix | Firebase Test Lab + physical devices | Android 9–15, iOS 16–18, low-end Android (2–3 GB RAM), Xiaomi / Samsung / Oppo |
| Performance | Flutter DevTools | Cold start < 2 s on a mid-range phone, 60 fps scrolling, no jank on video screens |
| Battery (background modules) | Android Battery Historian, Xcode Energy Log | Per-module budget (see module) |
| Accessibility | TalkBack, VoiceOver, 200 % font scale | All controls labelled, no clipped text |
| Manual QA | Test checklist per module | Signed off before every release |

### 5.3 Release
- [ ] CI (GitHub Actions): analyze → test → build on every PR; release build on tag
- [ ] Crash reporting (Firebase Crashlytics or Sentry), with **crash-free sessions ≥ 99.5 %** as the release target
- [ ] Release flow: internal testing → closed beta → open beta → production staged rollout (10 % → 50 % → 100 %)
- [ ] Release notes in English + Urdu
- [ ] Privacy policy and store data-safety forms updated if the module touches new data

---

## Phase 0 — Foundation & release blockers

**Goal:** make the current app safe to ship and ready to grow. **Duration:** ~2–3 weeks.

### 0.1 Release blocker fixes (from the code audit)

**Scope**
- iOS: add `GADApplicationIdentifier`, `SKAdNetworkItems` and `NSUserTrackingUsageDescription` to `ios/Runner/Info.plist`
- Ad IDs: use Google test IDs when `kDebugMode`; fail the release build if any `String.fromEnvironment` ad ID is empty
- Consent: add the UMP consent flow (GDPR) and App Tracking Transparency on iOS before any ad request
- Stop the app-open ad from showing right after an interstitial, or after returning from the share sheet or a purchase
- Banner: guard against parallel loads; reserve banner space only once an ad has loaded
- Input validation: height 50–272 cm, weight 2–635 kg; an empty field blocks calculation
- Share and goal overlays use the BMI and weight of the entry being viewed
- Show the version from `package_info_plus`, not hard-coded text

**Testing**
- Unit tests: `BmiCalculator`, `UserProfile.heightInCm` / `weightInKg`, validation bounds
- Manual: iOS launch on a real device; ad consent in an EU region (VPN); interstitial → resume → no app-open ad
- **Done when:** iOS launches without a crash, no real ads are served in debug, and the consent prompt appears for EU users

### 0.2 Architecture refactor

**Scope**
- [x] Upgrade Kotlin 1.8.22 → 2.1.0
- [x] Move to the feature-folder structure in §2; existing BMI screens now live in `features/body/bmi/`
- [x] Replace the Stack-overlay navigation with **go_router** (`lib/app/router.dart`): tabs keep their state, result/goal/share are real pages, Android back works
- [x] Numbered schema migrations on the existing `sqflite` database (`DatabaseHelper._migrations`), v1 → v2 adds a history date index. Kept `sqflite` instead of moving to drift: no code generation, zero change to how existing users' data is stored. Revisit drift in Phase 1 if the number of tables makes raw SQL painful.
- [ ] Split `AppProvider` into feature providers. Deferred to Phase 1.1, where the profile is rebuilt anyway.
- [x] Crash reporting with **Sentry** (`lib/core/monitoring/crash_reporting.dart`): wraps app start-up, off unless `SENTRY_DSN` is in `.env.json`, never in debug. No PII, screenshots or view hierarchy; navigation/console breadcrumbs dropped because routes carry BMI values. `reportError()` for handled errors. Privacy dialog (en/ur) and `privacy-policy.md` updated.
- [x] English + Urdu localization (`lib/l10n/*.arb`, `tool/gen_arb.py`): all 175 user-facing strings, plurals, Urdu dates, RTL layout checked on an emulator. Language picker in Settings. Urdu stays hidden in release builds (`FeatureFlags.urdu` in `lib/core/config/feature_flags.dart`; force with `--dart-define=FLAG_URDU=true`) until a native speaker reviews the translations. Paywall strings are left for Phase 3.5 (premium launch).

**Testing**
- [x] Migration tests (`test/database_migration_test.dart`): a v1 database with real BMI history upgrades with zero data loss; fresh and upgraded installs end with identical schemas
- [x] Navigation widget tests (`test/navigation_test.dart`): back button on tabs and on the result page
- [ ] Integration test: full BMI flow (enter → calculate → save → history → delete) on a real device
- **Done when:** the app behaves exactly as before for existing users, and the back button works everywhere

### 0.3 Engineering infrastructure

**Scope**
- [x] GitHub Actions: `ci.yml` (analyze, tests, stale-translation check, dev APK on every push/PR) and `release.yml` (signed prod AAB on `v*` tags, tag must match pubspec version). Needs the repo on GitHub plus the signing/env secrets listed in the file.
- [x] Android flavors `dev` / `staging` / `prod`: dev and staging install side by side ("BMI Health Dev", "BMI Health Staging"); prod keeps `com.bmihealth.bmi_health`. `make run`, `make check`, `make release`, and VS Code launch configs.
- [ ] iOS flavors (Xcode schemes/configurations): set up together with the first App Store release
- [x] Feature flags (`lib/core/config/feature_flags.dart`): build-time defaults, overridable per build with `--dart-define=FLAG_…`; Urdu and ads are behind flags. Remote Config can replace this when remote switches are needed.
- [x] Test helpers: shared app harness (`test/helpers/app_harness.dart`), in-memory/temporary database via `sqflite_common_ffi`. Fake clock/location/health-data helpers get added with the features that need them (Phase 1–2).

**Done when:** every PR runs CI automatically, and a release build can be produced from a git tag.

---

## Phase 1 — Core health & gym MVP

**Goal:** the first public version as a health and gym app. **Duration:** ~6–8 weeks.

### 1.1 Profile & onboarding v2

> **Status: done** (1.1a `e86e9c8`, 1.1b). Profile lives in the database (schema v3) with a one-time import of the v1.0 profile; `AppProvider` is split into Settings/Profile/BMI providers. Setup flow: name → gender (+ formula basis and trainer for "Other") → body → goal → experience → equipment → days, shown after the intro and once to existing users ("Later" available), editable from Settings → Personal details. Inter is now bundled (no runtime font downloads).

**Features**
- Onboarding flow: name → gender → age → height and weight → goal (lose fat / build muscle / get stronger / stay fit) → experience level → equipment (gym / home / none) → training days per week
- Gender-aware steps as defined in §3 (demonstrator preference, formula basis for `o`)
- Existing users: a short "complete your profile" flow; BMI data carries over

**Technical**
- `UserProfile` v2 with the fields from §3, plus `goal`, `experience`, `equipment`, `daysPerWeek`
- Store the profile in the database (not SharedPreferences), with a migration from the current prefs keys

**Testing**
- Unit: profile migration from prefs; gender → demonstrator / formula resolution
- Widget: every onboarding step, including back navigation and validation
- Integration: new user onboarding; existing user upgrade keeps BMI history

**Done when:** new and existing users both reach the Today tab with a complete profile, and changing gender in Profile updates the demonstrator and formulas immediately.

### 1.2 Body module (existing BMI + new metrics)

> **Status: done** (1.2a `2ec79b6`, 1.2b). Body tab replaces the History tab (History opens from it). Weight log with 7-day trend chart (existing BMI entries imported as weight history), gender-specific measurements, US Navy body-fat estimate, disclaimer. Logging a weight also updates the calculator's weight. Not yet: editing/deleting single weigh-ins and measurements from the UI (storage supports it), progress photos (Phase 4.6).

**Features**
- **BMI (existing):** calculator, history, goals, share, tips, moved into Body
- **Weight tracking:** quick log, 7-day moving-average trend, goal line
- **Body measurements:** gender-specific fields (§3), with history charts
- **Body fat estimate:** US Navy method (gender-specific formula)
- Medical disclaimer on every result screen

**Technical**
- Tables: `weight_logs`, `measurements`, `body_fat_logs`
- Pure functions in `domain/` for the Navy formula and moving average

**Testing**
- Unit: Navy formula for male and female against published reference values; edge cases (waist < neck)
- Golden: charts with 0, 1, 2 and 100+ entries
- **Done when:** results match the reference values to ±0.1 %, and charts stay smooth with 2+ years of data.

### 1.3 Exercise library (human videos)

> **Status: built, waiting for video content.** 30-exercise bundled catalog (`assets/exercises/catalog.json`, English + Urdu names, form steps), search, muscle filter and "my equipment" filter from the profile, detail page with the gender-matched demonstrator player (falls back to the other demonstrator, "Video coming soon" placeholder until clips exist). Not yet: remote catalog download, offline video cache, Urdu form steps, the remaining 70 exercises.

**Features**
- 100 exercises with male and female human videos (§4)
- Filters: muscle group, equipment, difficulty, home/gym
- Exercise detail: loop video, tutorial, step-by-step text, common mistakes, target muscles
- Video picked automatically from the gender / demonstrator preference

**Technical**
- Catalog JSON downloaded from the CDN and cached in the database; bundled fallback catalog for first launch offline
- `video_player` (or `media_kit`) with HLS; `flutter_cache_manager` for the offline loop cache (size limit, e.g. 500 MB, LRU)
- Thumbnail placeholders while videos buffer

**Testing**
- Unit: catalog parsing, version upgrades, demonstrator resolution
- Integration: offline mode (airplane) shows cached videos and text instructions
- Performance: first frame of a cached loop < 300 ms; library list at 60 fps
- Manual: every one of the 200 clips plays and has the right demonstrator gender (QA spreadsheet)
- **Done when:** all launch exercises play in both genders, offline fallback works, and the cache stays under its limit.

### 1.4 Workout tracker

> **Status: done (MVP).** Train tab: start empty or from a routine, add exercises via the library picker, sets prefilled from last time with a "previous" column, tick sets, 90 s rest timer with haptic, swipe to delete a set, finish summary (duration, volume, PRs) with save-as-routine, recent workouts with PR badges. Every change is saved immediately (survives the app being killed). Schema v5. Not yet: background rest-timer notification, set types (warm-up/drop), RPE, editing finished workouts, charts.

**Features**
- Start an empty workout, a saved routine, or repeat the last workout
- Log sets: weight, reps, RPE, warm-up / working / drop set
- Rest timer with notification and vibration; keeps running when the app is in the background
- Routines: create, edit, reorder, duplicate
- Workout summary: duration, volume, PRs
- Personal records and estimated 1RM (Epley formula)

**Technical**
- Tables: `workouts`, `workout_exercises`, `sets`, `routines`, `routine_exercises`, `personal_records`
- Active workout state saved after every set (survives the app being killed)
- `flutter_local_notifications` for the rest timer

**Testing**
- Unit: volume, 1RM and PR detection; kg/lbs conversion without rounding drift
- Integration: kill the app mid-workout → reopen → workout restored
- Manual: rest timer with the screen locked on Android and iOS
- **Done when:** no data is lost when the app is killed, and PRs are detected correctly across 1,000+ seeded sets.

### 1.5 Fuel v1 — calorie & macro targets

> **Status: done.** Mifflin-St Jeor BMR (sex-specific, "Other" uses formula basis), activity from training days, goal adjustment, safety floor (1200/1500 kcal), protein by goal, 25 % fat, water ≈ 35 ml/kg. Fuel tab: calories left, macros, water ±250 ml, quick food log with optional protein, swipe to delete. Schema v6. Not yet: per-entry carbs/fat, custom activity level, history beyond today.

**Features**
- BMR and TDEE (Mifflin-St Jeor, gender-specific), activity level, goal adjustment (cut / maintain / bulk)
- Protein, carb and fat targets
- Water tracker with a daily goal
- Quick calorie log (calories + optional macros, no food database yet)

**Testing**
- Unit: BMR/TDEE against reference calculations for male, female and the `o` formula basis
- **Done when:** targets update immediately when weight, goal or gender changes.

### 1.6 Today dashboard v1

> **Status: done.** New home tab: weekly workouts vs plan with start/resume, calories, water, latest weight, last BMI, tip of the day (rotates daily). Tabs are now Today · Body · Train · Fuel · Settings; the BMI calculator lives under Body, all tips under Today → More tips.

**Features**
- Today's workout card, water, weight check-in, calories left, weekly workout streak

**Testing**
- Widget: each card in empty and filled states
- **Done when:** dashboard loads in < 500 ms with a full year of data.

### Phase 1 release
- Update the store listing: new name, screenshots and description (keep package ID `com.bmihealth.bmi_health`)
- Update the privacy policy and data-safety form
- Closed beta with 20+ testers for 2 weeks before production

---

## Phase 2 — Movement & daily life tracking

**Goal:** add the signature movement timeline and automatic gym check-in. **Duration:** ~8–10 weeks.

### 2.1 Steps & health platform sync

> **Status: steps done.** `health` package, read-only STEPS on Health Connect / HealthKit, asked only from the Connect button; install prompt when Health Connect is missing; refresh on app resume; daily goal 8,000; privacy policy updated. **minSdk raised to 26** (Android 8.0) as Health Connect requires. Verified on an Android 16 emulator incl. revoke → reconnect. Not yet: hourly chart, distance/active calories, sleep & heart rate, custom step goal. Play Console needs the Health Connect permission declaration before release.

**Features**
- Daily steps, distance and active calories; hourly breakdown chart
- Daily step goal with a ring on the Today tab
- Read sleep and heart rate when available (used later by Recovery)

**Technical**
- `health` package: **Health Connect** (Android) and **HealthKit** (iOS)
- Fallback: `pedometer` with the `ACTIVITY_RECOGNITION` permission
- Read-only permissions in v1; ask only for the data types actually used

**Testing**
- Integration: with Health Connect installed and not installed; permission denied
- Manual: compare step counts with Google Fit / Apple Health over 3 days (target within ±5 %)
- **Done when:** steps match the platform within 5 %, and the app works without Health Connect.

### 2.2 Movement timeline (signature feature)

> **Status: done (free approach).** `geolocator` stream as a visible Android foreground service started from the app — **no ACCESS_BACKGROUND_LOCATION** (no background-location declaration/video needed; only the foreground-service `location` declaration). ~1 fix/minute, stays ≥5 min within 100 m become visits, trips classed walk/run/vehicle by speed, noisy fixes dropped, named places, OpenStreetMap map with route, day picker, delete day/all, auto-resume on launch, follows today across midnight. Verified on emulator with simulated GPS. **Limits:** stops if the app is swiped away (restarts on next open); OEM battery savers may pause it; OSM's public tile server is for light use — switch to a paid tile provider before scale.

**Features**
- Daily timeline: places visited, arrival and departure times, **time stayed at each place**
- Route map between places, coloured by activity (walk / run / cycle / vehicle)
- Steps, distance and calories per segment
- Place labels (Home, Gym, Office, custom) remembered for future visits
- Weekly insights: time at home / work / gym, most-visited places
- Edit and delete any visit, or a whole day; pause tracking; delete all location history

**Technical**
- Background location: `flutter_background_geolocation` (needs a paid licence for Android release; best battery and reliability) **or** `geolocator` plus a custom foreground service (free, more work)
- Activity recognition for walk / run / vehicle / still
- **Stay detection:** cluster points within ~100 m for ≥ 5 min → a `visit`; between visits → a `trip`
- **Route simplification:** Douglas-Peucker before saving; raw points kept for at most 24 h
- Reverse geocoding through the platform `geocoding` package, cached per place
- Map: `flutter_map` + OpenStreetMap tiles (check the tile usage policy; use a paid tile provider at scale)
- Tables: `places`, `visits`, `trips`, `trip_points` (simplified), `raw_points` (short-lived)
- **All location data stays on the device.** It is never sent to analytics, ads or any server.

**Battery budget:** ≤ 4 % per day on a mid-range Android phone with normal daily movement.

**Testing**
- Unit: stay-detection and trip-segmentation algorithm with recorded GPS traces (walk, drive, indoor GPS drift, tunnels)
- Integration: fake location stream → expected visits and trips
- Field tests: 2 weeks of daily use on at least 3 Android brands + 1 iPhone, logging battery use and accuracy
- OEM battery-saver tests on Xiaomi, Samsung, Oppo and Vivo, with a guide screen for "disable battery optimisation"
- Privacy review: confirm no location in logs, analytics or crash reports
- **Done when:** ≥ 90 % of stays over 10 min are detected, battery stays within budget, and the Play background-location declaration is approved.

### 2.3 Automatic walk & run detection

> **Status: partly done.** Trips in the timeline are classified walk / run / vehicle with distance and duration. Not yet: per-run pace & splits, manual start/stop cardio sessions.

**Features**
- Detects walks and runs over 10 min; shows route, pace, splits and calories
- Manual start and stop for outdoor cardio sessions

**Testing**
- Field test: 20 recorded walks and runs compared with a reference app (distance within ±3 %)

### 2.4 Automatic gym check-in (signature feature)

> **Status: done.** Mark any visited place as "my gym"; after 3 minutes inside it (while tracking) a notification offers to start the workout, at most once per 3 h; weekly gym time on Today. Not yet: linking the gym visit to the logged workout, attendance calendar.

**Features**
- User marks their gym on the map (or picks a place from the timeline)
- Arriving at the gym → notification: "At the gym. Start today's workout?"
- Gym time logged automatically; the workout is linked to the visit
- Monthly gym attendance calendar

**Technical**
- Geofence (radius 100–150 m) through the background geolocation layer
- Dwell trigger (≥ 3 min inside) to avoid false alerts when passing by

**Testing**
- Field test: 20 gym visits plus 20 drive-bys; target ≥ 95 % correct check-ins and ≤ 1 false alert
- **Done when:** check-in is reliable, and the notification opens the right routine in one tap.

### 2.5 Sitting alerts & reminders

> **Status: reminders done.** Daily (8 PM) and weekly (Sunday 10 AM) local notifications from the Settings toggles; permission asked on first enable (declined → toggle stays off with an explanation); localised text; inexact scheduling (no exact-alarm permission); survive reboot; App Open ad suppressed around the permission prompt. Not yet: custom times, workout/water/weigh-in specific reminders, sitting alerts (needs activity data, Phase 2.1).

**Features**
- "You've been still for 2 hours": walk reminder (respects quiet hours and sleep)
- Workout, water and weigh-in reminders (makes the existing notification toggles real)

**Testing**
- Unit: reminder scheduling across time zones and daylight saving
- Manual: reminders fire with the app killed, on Android 13+ (exact alarm and notification permissions)

### Phase 2 release
- Google Play: **background location declaration + demo video**, **Health apps declaration**, Health Connect permission declaration
- iOS: "Always" location usage text, HealthKit entitlement, App Privacy labels
- Staged rollout starting at 5 % because of battery risk; monitor ANRs and battery complaints

---

## Phase 3 — Smart training & premium launch

**Goal:** coaching features worth paying for. **Duration:** ~8 weeks.

### 3.1 Programs

> **Status: done (v1).** 5 built-in programs (home full body, beginner gym full body, glutes & lower, PPL, 5×5), ordered by equipment fit, goal, experience and gender — all open to everyone; one tap starts a program day. Not yet: weekly schedule tracking, automatic deloads.
- Ready-made programs: beginner full body, push/pull/legs, upper/lower, 5×5, home no-equipment, glutes and lower body, fat-loss conditioning
- Recommendations based on goal, experience, equipment, days per week and gender (§3), with every program available to everyone
- Weekly schedule with automatic deload weeks
- **Testing:** unit tests for schedule generation; widget tests for program switching mid-cycle

### 3.2 Progressive overload suggestions

> **Status: done.** Double progression (8–12 reps): top of range → +weight (2.5 kg barbell, 2 kg dumbbell…), in range → +1 rep, missed twice → −10 % deload; bodyweight by reps; shown under each exercise in the logger.
- "Last time 60 kg × 10 → try 62.5 kg × 8–10 today", based on RPE and history
- **Testing:** unit tests with simulated 12-week histories (stall, progress, missed sessions)

### 3.3 Muscle heatmap

> **Status: done as heat bars.** Weekly hard sets per muscle (secondary = ½), colour-coded, under-trained list. The front/back body diagram (gender-specific) needs illustration assets.
- Front and back body diagram (gender-specific body model) shaded by weekly volume per muscle
- Shows under-trained muscles with suggested exercises
- **Testing:** golden tests for both body models in light and dark mode

### 3.4 Camera rep counter & form check

> **Status: built; accuracy not yet measured on people.** Front camera (falls back to back), ML Kit pose (on device, nothing recorded), squat / push-up / curl / shoulder press / lunge counted from joint angles with hysteresis and 3-frame smoothing, best-visible body side, cues: go lower, keep hips up, full range, step into frame; "Log set" adds the reps to the active workout. Verified on emulator: permission, preview, frames reach ML Kit (CameraX YUV→NV21 conversion added). **Still required:** the 50-sets-per-exercise accuracy study on real people (target ≥95 %) and threshold tuning. **Size:** ML Kit adds ~21 MB per device (arm64 download now ~50 MB); consider Play Feature Delivery for the rep counter.
- Counts reps for squats, push-ups, lunges, curls, shoulder press and jumping jacks
- Live form cues: depth, knee position, back angle
- Runs fully on the phone; **no video is saved or uploaded**

**Technical:** Google ML Kit Pose Detection (`google_mlkit_pose_detection`); joint-angle state machine per exercise.

**Testing**
- Recorded test videos: 50 sets per exercise, both genders, several body types, lighting conditions and camera angles
- Target: rep count accuracy ≥ 95 %; form cue false-alarm rate ≤ 10 %
- Performance: ≥ 20 fps pose inference on a mid-range phone; temperature check over a 20-min session

### 3.5 Premium launch

> **Status: built; needs your accounts to go live.** `functions/` HTTPS function verifies receipts with Google Play (subscriptionsv2 / products) and Apple (App Store Server API) and returns an ES256-signed entitlement; the app verifies it with a bundled public key (no Firebase SDK in the app). Grace period / cancelled-until-expiry handled; entitlement re-checked at least every 35 days; offline keeps premium until then; restore timeout; purchase always acknowledged. Premium removes all ads. Paywall rewritten: only real benefits, store prices only, localised. Hidden until `PREMIUM_VERIFY_URL` + `ENTITLEMENT_PUBLIC_KEY` are set. **To go live:** follow `functions/README.md` (Firebase Blaze project, keys, Play service account, App Store key), create the 3 products in both stores, add Terms of Use + Privacy Policy links to the paywall (Apple requirement). **Decide:** which features (if any) beyond ad removal become premium-only.
- Premium: no ads, all programs, overload suggestions, rep counter, advanced charts, timeline insights
- Fix the purchase service from the audit: server-side receipt validation (Google Play Developer API / App Store Server API), subscription expiry handling, restore with timeout
- Hide ads for premium users everywhere
- **Testing:** Play and App Store sandbox purchases, renewals, cancellation, refund, restore on a new device, offline launch with a cached entitlement

---

## Phase 4 — Health intelligence

**Goal:** daily health insight from all the data collected. **Duration:** ~8–10 weeks.

### 4.1 Recovery score

> **Status: done.** 0–100 from sleep, resting HR and HRV vs. 14-day baseline (if connected), training load (last 2 days vs. 4-week norm) and a 1–5 soreness check-in; missing factors re-weighted; one very bad sign (e.g. illness HR spike) caps it at 40 → rest. Advice: train hard / light / rest plus the main limiting factor. Health data is a separate optional Connect.
- Daily 0–100 score from sleep, resting heart rate, HRV (if a wearable provides it), training load and soreness check-in
- Tells the user whether today is for training hard, training light or resting
- **Testing:** unit tests with synthetic data covering missing data (no wearable), illness spikes and overtraining

### 4.2 Sleep insights

> **Status: done (v1).** Watch segments merged into nights, naps ignored; last night, 7-night average, weekly sleep debt vs. 8 h, bedtime regularity. Not yet: sleep stages, trends chart, bedtime reminder.
- Sleep duration and consistency from Health Connect / HealthKit, and bedtime reminders

### 4.3 Cycle tracking & cycle-aware training (opt-in, for female / other profiles)

> **Status: done.** Settings opt-in (only for profiles that offer it; explanation dialog first), period start/end + past periods, 8 symptoms per day, prediction from the median of the last 6 cycles with a window that widens for irregular cycles, missed-log gaps ignored, late notice, phase (period / follicular / ovulation / luteal) with training & nutrition tips. Optional fingerprint/PIN lock (needs one successful unlock to enable; re-locks when the app is backgrounded; Today hides details while locked). One-tap delete. Schema v8. No backup exists yet, so nothing leaves the phone. Tips need a review by a women's-health professional before release.
- Period and symptom log, phase prediction, training and nutrition tips per phase
- **Extra privacy:** separate opt-in, optional app lock (biometric), never included in backup unless the user chooses it, one-tap delete
- **Testing:** unit tests for prediction with irregular cycles; privacy review

### 4.4 Food logging, barcode scanner & food photo estimate

> **Status: barcode done; photo estimate built (see 4.5).** EAN/UPC scanning (mobile_scanner 7.0.1 — newer versions need AGP 8.9/SDK 36), Open Food Facts lookup (kcal, kJ fallback, protein, serving size; nonsense values rejected), serving/50/100/200 g or custom grams, logs kcal + protein, last 60 products cached for offline, manual entry fallback for not found / no nutrition / offline, ODbL credit shown. **Still to do:** the 100-local-products accuracy check (Pakistani products are thinly covered in Open Food Facts — expect many "not found"); carbs/fat logging.
- Food database search and barcode scanning (Open Food Facts API, cached locally)
- Food photo → estimated calories and macros using a vision AI model. The user always confirms or edits the result.
- Pakistani / South Asian food entries (roti, daal, biryani, etc.) added to the local database
- **Testing:** barcode accuracy on 100 local products; photo estimate compared with known portions (shown clearly as an estimate)

### 4.5 AI coach

> **Status: built; needs your Anthropic key + deploy.** Firebase functions `coach` and `estimateFood` call Claude Opus 5.5 (`claude-opus-5-5`; effort low for chat, medium for photos; server-side refusal fallback on). Emergencies (chest pain, fainting, self-harm…) get a fixed "contact 1122 / a doctor" reply without calling the AI; system prompt limits it to general fitness, no diagnosis, no extreme diets. Input validation, profile values whitelisted (no prompt injection via profile), 30 chats / 15 photos per install per day via Firestore counters, nothing stored or logged. App: one-time consent dialog naming what is sent, chat kept in memory only, food-photo estimate with per-item selection, "(estimate)" label and a ±20–40 % note. Hidden until `COACH_URL` / `FOOD_PHOTO_URL` are set. **Still required before launch:** the 200-question prompt evaluation set (unsafe + medical questions), Firebase App Check, an Anthropic spend limit, Urdu reply review, and the photo-estimate accuracy check against known portions.
- Weekly summary written in plain language (English / Urdu)
- Chat with a coach about workouts and nutrition; can generate or adjust a program
- Guardrails: no medical diagnosis, an emergency-symptom warning, and the disclaimer
- Sends only the minimum data needed, with the user's consent; never location or cycle data unless the user asks
- **Testing:** prompt evaluation set (200+ questions covering unsafe and medical questions), cost per user monitoring, rate limiting

### 4.6 Progress photos

> **Status: done.** Camera or gallery (downscaled to 1440 px), AES-256-GCM encrypted into the app's private folder with the key in Android Keystore / iOS Keychain; never written to the gallery; tamper-evident; thumbnails, full view, first-vs-latest side-by-side with dates and weight; delete removes the file. **Also fixed app-wide:** Android cloud backup and device transfer were on by default (health, location and cycle data were going to Google Drive) — now off via allowBackup=false + data extraction rules; on iOS the database and photo folders are excluded from iCloud backup. Not yet: pose guide overlay, choosing which two photos to compare.
- Pose-guided capture (outline overlay so every photo has the same angle)
- Before / after slider and monthly collage
- Stored encrypted in app storage; hidden from the phone's gallery
- **Testing:** encryption check, gallery visibility on Android and iOS, delete removes the files from disk

---

## Phase 5 — Engagement, sync & wearables

**Goal:** retention and multi-device support. **Duration:** ongoing.

### 5.1 Weekly & monthly recap

> **Status: done (monthly).** This / last month: workouts, sets and kg lifted, PRs, training time (forgotten open workouts ignored), km moved and gym time from the timeline, weight change; shared as an image with totals only — never places or routes.
- "This month: 84 km walked, 9 h at the gym, 3 new PRs" as a shareable card (no location shown on shared cards)

### 5.2 Streaks, badges & challenges

> **Status: done (solo).** Week streak against the profile's days-per-week goal (the running week never breaks it), 10 badges with progress bars (workouts, streaks, PRs, 1,000 kg lifted, 10k steps), Today streak card. Not yet: challenges with friends (needs accounts + a backend).
- Workout streaks, step challenges, PR badges; optional challenges with friends

### 5.3 Backup & sync (opt-in)

> **Status: backup/restore/export done; live sync not built.** Passphrase-encrypted backup file (PBKDF2-SHA256 200k → AES-256-GCM over gzipped JSON of all tables + prefs), saved anywhere via the share sheet; cycle data and photos only if ticked (photos re-encrypted with the new phone's key on restore); device-specific prefs not copied; wrong passphrase / damaged / foreign / newer-version files refused without touching data; restore replaces data in one transaction and reloads the app live. CSV export of weights, workout sets and food (warns it is unencrypted). Tested: 730 weights + 4,500 sets + 1,440 location points round-trip. **Not built:** automatic background sync between devices (needs accounts + a backend).
- End-to-end encrypted backup (e.g. to the user's Google Drive / iCloud, or your own backend)
- Restore on a new phone; data export as CSV / JSON
- **Testing:** backup → wipe → restore with large datasets; corrupted backup handling; encryption audit

### 5.4 Wearables
- Wear OS and Apple Watch companion: active workout, rest timer, heart rate during sets
- **Testing:** pairing, phone disconnect mid-workout, battery use on the watch

---

## 12. Store compliance checklist

| Requirement | Phase | Platform |
|---|---|---|
| AdMob App ID in Info.plist, SKAdNetwork IDs | 0 | iOS |
| UMP consent (GDPR) and App Tracking Transparency | 0 | Both |
| Data safety form / App Privacy labels updated | Every release | Both |
| Medical disclaimer in app and store listing | 1 | Both |
| Health apps declaration | 2 | Google Play |
| Health Connect permissions declaration | 2 | Google Play |
| Background location declaration + demo video | 2 | Google Play |
| "Always" location and HealthKit usage descriptions | 2 | iOS |
| Foreground service type declarations (`location`, `health`) | 2 | Android 14+ |
| Exact alarm / notification permissions | 2 | Android 13+ |
| Camera usage description (rep counter) | 3 | Both |
| Subscription terms, restore button, cancellation info on paywall | 3 | Both |
| Model releases and video licences on file | 1 | — |
| Privacy policy covers location, health, camera, AI and backup | Each phase | Both |

---

## 13. Risks & mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Play rejects background location | Timeline cannot launch | Make the timeline a prominent core feature; clear demo video; foreground-only mode as a fallback |
| Battery drain complaints | Uninstalls, bad reviews | Battery budget per module, adaptive GPS sampling, staged rollout, settings to lower accuracy |
| OEM battery savers kill tracking | Gaps in the timeline | Per-brand guide screen; detect gaps and explain them to the user |
| Video production cost and time | Phase 1 delay | Film the top 100 exercises first; use licensed stock clips to fill gaps |
| Wrong form shown in videos | User injury, trust loss | Certified trainers only; a second trainer reviews every clip |
| Health / location data leak | Legal and trust damage | Data stays on device, no location in logs or analytics, encryption for photos, cycle and backup |
| AI cost per user | Losses on free users | AI features only in premium, rate limits, cache weekly summaries |
| Scope too large for one developer | Nothing ships | Ship each phase on its own; feature flags; cut Phase 4–5 items before cutting quality |

---

## 14. Timeline summary

| Phase | Focus | Estimate (1 developer) | Key release gate |
|---|---|---|---|
| **0** | Release blockers, architecture, CI | 2–3 weeks | iOS launches, consent works, BMI data migrates safely |
| **1** | Profile v2, Body, exercise library (human videos), workout tracker, Fuel v1, Today | 6–8 weeks (+ video production in parallel) | 200 clips QA'd, no data loss, closed beta passed |
| **2** | Steps, movement timeline, walk/run detection, gym check-in, reminders | 8–10 weeks | Battery ≤ 4 %/day, Play declarations approved |
| **3** | Programs, overload, heatmap, camera rep counter, premium | ~8 weeks | Rep accuracy ≥ 95 %, purchases verified on the server |
| **4** | Recovery, sleep, cycle tracking, food logging, AI coach, progress photos | 8–10 weeks | Privacy review passed, AI safety evals passed |
| **5** | Recaps, challenges, backup & sync, wearables | Ongoing | Restore tested on large datasets |

**Total to Phase 3 (full gym + movement app with premium): ~6–7 months for one developer.**
Estimates assume full-time work and that video filming runs in parallel with Phase 0–1 development.
