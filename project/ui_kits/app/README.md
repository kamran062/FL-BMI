# BMI Health — Mobile UI kit

A high-fidelity, click-through prototype of the entire BMI Health mobile app, built as the **single product surface** of this design system. Every component matches the tokens in `../../colors_and_type.css`.

> 📱 Open **`index.html`** in a browser. The phone in the middle is interactive — the sidebar on the left lets you jump straight to any screen during design review.

---

## What's in here

| File | Purpose |
|---|---|
| `index.html` | Composer — loads React, Lucide, fonts, and all the JSX modules below. |
| `ios-frame.jsx` | Starter device bezel (status bar, dynamic island, home indicator). |
| `components.jsx` | Shared primitives: `Button`, `Field`, `Segmented`, `Toggle`, `Card`, `StatusPill`, `BMIGauge`, `Screen`, `ScreenHeader`, `BottomNav`, `Icon`, plus the `bmiCategory` / `calcBMI` helpers. |
| `screens-flow.jsx` | `SplashScreen`, `OnboardingScreen`, `HomeScreen`, `ResultScreen`, `ShareCardScreen`. |
| `screens-tabs.jsx` | `HistoryScreen`, `GoalScreen`, `TipsScreen`, `PaywallScreen`, `SettingsScreen`. |
| `app.jsx` | Top-level `App` with phase / tab / overlay state and the review rail. |

All 10 screens specified in the brief are covered.

## What works

- **Splash** auto-advances to **Onboarding** (3 steps with dot indicator, skip + continue).
- **Calculator** — change height, weight, age, gender. Press **Calculate BMI** to reveal the result.
- **Result** — gauge animates to the computed BMI, recommendation copy adapts to the category, **Save** appends a History entry, **Set goal** opens the goal flow, **Share** opens the share card.
- **History** — line chart of recent BMIs, list of entries, empty state when there's nothing.
- **Goal** — target slider + timeline segmented; plan card updates live and flags unsafe rates.
- **Tips** — filter chips + featured card + Pro nudge.
- **Paywall** — three plan cards with selectable state and a "Best Value" badge.
- **Settings** — sections, toggles, dark-mode flip propagates into the iOS frame.

## What's intentionally simple

- No persistence — refresh resets state.
- "Share" doesn't actually export an image; it shows the card you'd share.
- No real localization; copy is in English.
- The line chart is built directly in SVG to avoid a chart library dependency.

## Notes / flags

- **Lucide** icons are loaded from CDN. The map of names → concepts lives in `../../README.md → Iconography`. Swap if you have a brand library.
- **Inter** is loaded from Google Fonts via `index.html`. The system stack falls back to SF Pro on Apple devices automatically.
- The device frame is the `ios_frame` starter component (iOS 26 liquid-glass style). For Android renders, swap it for `android_frame` — the screens are bezel-agnostic.
