# BMI Health — Design System

A premium, calming, evidence-based design system for **BMI Health**, a mobile app that calculates BMI, recommends actions, tracks progress, and converts users to a premium tier — all without an account.

> **Know Your Body. Improve Your Health.**

The system targets the feel of Apple Health (clinical clarity), Headspace (warm calm), and Stripe dashboards (premium minimalism), recast for a health-tracking single-purpose tool.

---

## Sources

This design system was built **from a written brief only** — no codebase, Figma file, screenshots, or existing assets were provided. Every token, asset, and component below is original and grounded in the brief's stated references (Apple Health / Headspace / Stripe) rather than a real brand library.

If you have any of the following, please share so the system can be tightened:

- An existing logo, wordmark, or app icon
- Brand guidelines or a tone/voice document
- Reference screenshots from a competitor or earlier draft you liked
- Specific font licenses (currently substituting SF Pro → Inter via Google Fonts — see `fonts/`)

---

## Quick facts

| Aspect | Decision |
|---|---|
| Surface | Mobile-first (iOS + Android). 390×844 base canvas. |
| Type | **Inter** (Google Fonts) — open substitute for SF Pro Display/Text. Tabular numerals enabled for all metrics. |
| Primary | `#1FB573` Vital Green — health, growth, the "normal" state. |
| Modes | Light + Dark, with paired neutrals and adjusted semantic colors. |
| Radii | 12 (chips), 16 (cards), 20 (hero cards), 24 (sheets / modals). |
| Shadow | 3-step elevation, very low spread, low opacity. No glow except splash. |
| Iconography | **Lucide** (CDN), 1.75 px stroke, 24 px grid — flagged as substitution. |
| Motion | Fast (150–250 ms), gentle ease-out. Springs only on success states. |

See `colors_and_type.css` for the full token list.

---

## CONTENT FUNDAMENTALS

The voice is **the calm-but-knowing trainer**: it tells you the truth, doesn't catastrophise, and always points at the next small action.

- **Pronoun:** Second-person `you`. The app never says "I" or refers to itself. Never "users" or "patients."
- **Casing:** Sentence case everywhere — titles, buttons, list rows. Title Case only on the wordmark.
- **Punctuation:** No exclamation marks in product UI (one acceptable exception: empty states). Periods on full sentences in body copy, omitted on short labels and buttons.
- **Numbers:** Always tabular. Units sit right after the value with a thin space (`24.3 kg/m²`). BMI to one decimal. Weight to one decimal.
- **Tone:** Honest, never alarmist. We say *slightly above the normal range*, not *unhealthy*. We say *a healthy range is 18.5–24.9*, not *you should be 24.9*.
- **Emoji:** Never in product chrome. Acceptable only inside a user-shared card if the user opts in. Default: none.
- **CTAs:** Verb-first, 1–3 words. `Calculate BMI`, `Save result`, `Set goal`, `Start tracking`, `Upgrade`.
- **Empty states:** One short sentence + one CTA. Optimistic, not apologetic. *"No history yet. Start tracking today."*
- **Errors:** State the problem, suggest the fix. *"Weight must be between 20 and 300 kg."*
- **Premium copy:** Aspirational, not pressured. *"Unlock your full health journey"* — never *"Don't miss out"*.

### Copy examples

| Surface | ✅ Use | ❌ Avoid |
|---|---|---|
| Result headline | `Your BMI is 26.4` | `BMI Result: 26.4!` |
| Result subline | `Slightly above the normal range` | `You are overweight ⚠️` |
| Advice card | `Aim for a 0.5 kg loss this week with a small calorie deficit and 30 min daily movement.` | `Lose weight fast! Try our tips.` |
| Empty history | `No history yet. Start tracking today.` | `Oops, nothing here yet 😅` |
| Paywall hero | `Unlock your full health journey` | `Upgrade now or miss out` |
| Goal CTA | `Start tracking goal` | `Submit` |

---

## VISUAL FOUNDATIONS

The system is **soft-clinical**: generous whitespace, low-contrast surfaces, one bold accent color, and large, confident numbers that carry the page.

### Color

- **One primary**, Vital Green `#1FB573`, used sparingly — primary CTAs, the "normal" BMI category, progress arcs, single-selection highlights.
- **Four semantic categories** map to BMI ranges. They always appear in the same order: blue (under), green (normal), amber (over), red (obese).
- **Neutrals are warm**, not pure grey. Backgrounds carry a 2–3 % green undertone so the surface feels alive.
- **Dark mode** flips to a deep charcoal `#0E1411` with a green undertone matching the light surface, not a flat black.

### Typography

- **One typeface — Inter.** Display tier uses `Inter` at weights 600/700 with `letter-spacing: -0.03em` for large numerics. Body uses 400/500 at default tracking. Captions are 13 px with 500 weight and `tracking-wide`.
- **Tabular numerals (`font-variant-numeric: tabular-nums`) on every metric** — BMI, weight, dates, prices.

### Spacing & Layout

- 4-px base grid. Scale: `4, 8, 12, 16, 20, 24, 32, 40, 48, 64`.
- Screen padding is **20 px horizontally** on phones. Cards are **20–24 px** internal.
- Vertical rhythm: 24 px between unrelated blocks, 12 px between related rows, 8 px inside a single component.
- Fixed bottom nav is **64 px tall**, sits on a translucent surface with a 12-px blur.

### Backgrounds

- **No photography in core chrome.** A single tactile gradient is reserved for the splash screen (`linear-gradient(180deg, #E8F7EF 0%, #FFFFFF 60%)`) and a darker mirror on the share card. Everywhere else: flat surfaces.
- No textures, no patterns, no illustration art. The data is the art.

### Motion

- **Durations:** 150 ms (micro), 220 ms (transitions), 320 ms (page).
- **Easing:** `cubic-bezier(0.22, 0.61, 0.36, 1)` (gentle ease-out) as the default. Springs only on success states (result reveal, goal achieved).
- **Splash pulse:** 2.4 s loop, ±4 % scale, opacity 0.6 → 1.
- **Page transitions:** push from right, 280 ms.
- **No bounces on buttons.** No rotate-in. No skeleton shimmers — use a soft 600 ms opacity fade.

### Interaction states

- **Hover** (web preview only): `filter: brightness(1.04)` on the primary, `background: rgba(0,0,0,0.04)` on neutrals.
- **Press:** `transform: scale(0.98)` over 120 ms, plus a `brightness(0.96)` darken on the primary. No ripple.
- **Focus:** 2 px Vital Green ring at 60 % opacity, offset 2 px from the element.
- **Disabled:** 40 % opacity. No tooltip required if the cause is obvious.

### Borders, shadows, elevation

- **Borders are rare.** Used only for input outlines (1 px `--border-subtle`) and dividers (1 px `--border-faint` at 6 % black / 10 % white).
- **Three elevations** — see `--elev-1`, `--elev-2`, `--elev-3` in `colors_and_type.css`. They are deliberately subtle; the system reads as flat-with-warmth, not as drop-shadow-heavy material.
- **No inner shadows.**
- **No glow halos** except the splash screen pulse.

### Corners & cards

- Inputs `12px`. Buttons `14px`. Cards `20px`. Sheets `24px` top corners only. Pills `9999px`.
- A card is: surface color + `--elev-1` + `20px` radius + `20px` internal padding. That's it. No outline.

### Transparency & blur

- The bottom navigation, the modal scrim, and the share-card export ribbon use `backdrop-filter: blur(12px)` over a 70 % opaque surface tint.
- Otherwise, surfaces are solid — translucency is reserved for chrome that sits over content.

### Imagery

- No photographic imagery in v1. The share card is the only "branded" surface and uses the primary gradient + the wordmark + the user's BMI number.

### Layout rules

- One **fixed bottom navigation** across primary screens (Home / History / Tips / Settings).
- Headers are **sticky on scroll** with the same surface tint as the body — no separator until the user scrolls, then a 1-px `--border-faint`.
- Floating action buttons are **not** used. Primary actions live in-flow.

---

## ICONOGRAPHY

The brief did not supply an icon set. **Lucide** is used as a substitute — it matches the soft-clinical tone (1.75 px stroke weight, generous geometry, no fills except in pictogram-style icons).

- **Delivery:** Loaded via CDN in HTML demos (`lucide@latest`). Production should bundle the npm package.
- **Stroke:** 1.75 px on a 24 px grid. Up-size by changing CSS `width/height`, not the stroke.
- **Color:** Inherits `currentColor`. Default `--fg-2` (secondary text) for chrome icons, `--fg-1` for active state, primary for the selected nav item.
- **Filled variants** are not used. Status badges use a colored dot, not a colored filled icon.
- **Unicode icons** are not used (no ✓ ✗ ★ etc.). Always Lucide.
- **Emoji** is not used in chrome.

Common mappings:

| Concept | Lucide name |
|---|---|
| Home / calculate | `calculator` |
| History | `line-chart` |
| Tips | `lightbulb` |
| Settings | `settings-2` |
| Share | `share` |
| Goal | `target` |
| Save | `bookmark` |
| Premium | `sparkles` |
| Underweight | `arrow-down` |
| Overweight | `arrow-up` |
| Normal | `check` |
| Back | `chevron-left` |

> ⚠️ **Flag:** This is a substitution. If the brand has an icon library, swap `lucide` for it in `ui_kits/app/index.html` and document the new mapping here.

---

## Index

```
README.md                  ← you are here
SKILL.md                   ← Agent-Skill manifest for downstream use
colors_and_type.css        ← Design tokens (colors, type, spacing, radius, elevation)
fonts/                     ← Inter (Google Fonts substitute for SF Pro)
assets/
  logo.svg                 ← Wordmark
  logomark.svg             ← Standalone leaf-pulse mark
  app-icon.svg             ← Rounded app icon (iOS-ready)
preview/                   ← Design system review cards (registered to the gallery)
  *.html
ui_kits/
  app/                     ← Mobile UI kit (the only product surface)
    README.md
    index.html             ← Click-through prototype of all 10 screens
    *.jsx                  ← Reusable React components
```

---

## Caveats / open questions

1. **No assets provided** — logo, icon, color, and type were all invented to match the brief's references. These should be reviewed against your real brand if one exists.
2. **Inter is a Google Fonts substitute for SF Pro.** Swap `fonts/Inter-*` and update `--font-sans` if you have the SF Pro license.
3. **Lucide is a substitute icon set.** Swap if you have a brand library.
4. **No real photography.** The share card uses a gradient + numbers only. If you want photographic moments anywhere (e.g., onboarding), share reference images.
