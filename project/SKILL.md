---
name: bmi-health-design
description: Use this skill to generate well-branded interfaces and assets for BMI Health, either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the `README.md` file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.

## Quick-start checklist

1. **Link tokens.** Always start with `colors_and_type.css` — it carries every design variable (colors, type roles, radii, elevation, motion). Import it before writing any markup.
2. **Match the voice.** Sentence case, second-person *you*, no exclamation marks, no emoji in chrome. See `README.md → CONTENT FUNDAMENTALS`.
3. **Use Inter** (or system SF Pro fallback). Tabular numerals on every metric — BMI, weight, dates, prices.
4. **Vital Green is sparing.** Use `--brand-500` only for primary CTAs, the "normal" BMI category, and active selections. Everything else is warm neutrals.
5. **BMI category color order is canonical:** blue (under) → green (normal) → amber (over) → red (obese). Never permute.
6. **Iconography:** Lucide via CDN at 1.75 px stroke / 24 px grid. Mappings in `README.md → ICONOGRAPHY`.
7. **Reuse the UI kit** in `ui_kits/app/` — it ships the device frame, every component primitive, and all 10 screens. Cherry-pick the components you need.

## Anti-patterns (do not do)

- Don't introduce gradients outside the splash + share-card surfaces.
- Don't use multiple accent colors. There is exactly one — Vital Green.
- Don't use emoji in product chrome.
- Don't use exclamation marks (one allowed exception: empty-state cheer).
- Don't use ✓ ✗ ★ etc. as text icons. Use Lucide.
- Don't draw your own SVG icons when Lucide has the concept.
- Don't ship without `font-variant-numeric: tabular-nums` on metrics.
