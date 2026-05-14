# Fonts

## Inter — substituted for SF Pro

The brief specified **SF Pro / Inter style**. SF Pro is Apple-licensed and cannot be redistributed in a generic design system, so this system standardizes on **Inter** (SIL Open Font License).

The CSS in `colors_and_type.css` falls back to the system font stack so iOS devices render real SF Pro automatically — the system gets the "right" feel on Apple devices while remaining portable everywhere else.

### To install Inter locally

Drop the variable WOFF2 into this folder:

```
fonts/Inter-Variable.woff2
```

Get it from https://rsms.me/inter/ → "Download Inter" → use `Inter.var.woff2` from the `web` folder, rename to `Inter-Variable.woff2`.

If the file is missing, the `@font-face` block in `colors_and_type.css` includes a Google Fonts CDN URL as a fallback `src`, so previews continue to work without a local install.

> ⚠️ **Flag:** This is a substitution. If you have SF Pro license rights, place `SF-Pro-Display-*.otf` and `SF-Pro-Text-*.otf` here, update the `@font-face` block, and change `--font-sans` in `colors_and_type.css`.
