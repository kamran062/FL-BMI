"""Build the app's small website (Firebase Hosting, free Spark plan).

    python3 -I tool/website/build_site.py

Writes website/public/:
  app-ads.txt     AdMob seller line (must be at the domain root)
  index.html      short landing page
  privacy/        privacy-policy.md as a page
  terms/          terms-of-use.md as a page

Deploy with `firebase deploy --only hosting`. The site address
(https://<project>.web.app) must be the "Website" in the Play Console store
listing and the App Store support URL, and the TERMS_URL / PRIVACY_URL in
.env.json should point to /terms and /privacy on it.
"""
import html
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "website" / "public"

# From AdMob → Apps → app-ads.txt. One line per ad network.
APP_ADS = "google.com, pub-8866184646479787, DIRECT, f08c47fec0942fa0\n"

APP = "BMI Calculator & Health"

PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">
<style>
  :root {{ --bg:#ffffff; --fg:#14201b; --muted:#5b6b64; --brand:#1d9e6a; --line:#e3e9e6; }}
  @media (prefers-color-scheme: dark) {{
    :root {{ --bg:#0e1412; --fg:#e8efec; --muted:#9aaba3; --brand:#34c78a; --line:#24302b; }}
  }}
  * {{ box-sizing: border-box; }}
  body {{ margin:0; background:var(--bg); color:var(--fg);
         font: 16px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }}
  main {{ max-width: 760px; margin: 0 auto; padding: 32px 16px 64px; }}
  nav {{ display:flex; gap:16px; flex-wrap:wrap; margin-bottom: 24px; font-size: 15px; }}
  a {{ color: var(--brand); }}
  h1 {{ font-size: 30px; line-height: 1.25; margin: 0 0 12px; }}
  h2 {{ font-size: 21px; margin: 32px 0 8px; }}
  h3 {{ font-size: 17px; margin: 22px 0 6px; }}
  hr {{ border: 0; border-top: 1px solid var(--line); margin: 28px 0; }}
  li {{ margin: 4px 0; }}
  footer {{ margin-top: 48px; color: var(--muted); font-size: 14px; }}
</style>
</head>
<body>
<main>
<nav><a href="/">{app}</a><a href="/privacy">Privacy Policy</a><a href="/terms">Terms of Use</a></nav>
{body}
<footer>&copy; Kamran Iqbal · <a href="mailto:kamraniqbal.bcs062@gmail.com">kamraniqbal.bcs062@gmail.com</a></footer>
</main>
</body>
</html>
"""


def inline(text: str) -> str:
    """Escape, then bold, italics and links."""
    t = html.escape(text, quote=False)
    t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", r'<a href="\2">\1</a>', t)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"<em>\1</em>", t)
    return t


def markdown(md: str) -> str:
    """The subset our policy documents use: headings, paragraphs (with line
    breaks), bullet lists, horizontal rules, bold, italics and links."""
    out, para, items = [], [], []

    def flush():
        if para:
            out.append("<p>" + "<br>\n".join(inline(l) for l in para) + "</p>")
            para.clear()
        if items:
            out.append("<ul>\n" + "\n".join(f"<li>{inline(i)}</li>" for i in items) + "\n</ul>")
            items.clear()

    for raw in md.splitlines():
        line = raw.rstrip()
        if not line.strip():
            flush()
        elif line.strip() == "---":
            flush()
            out.append("<hr>")
        elif m := re.match(r"(#{1,3}) (.*)", line):
            flush()
            n = len(m.group(1))
            out.append(f"<h{n}>{inline(m.group(2))}</h{n}>")
        elif m := re.match(r"\s*- (.*)", line):
            if para:
                flush()
            items.append(m.group(1))
        else:
            if items:
                flush()
            para.append(line.strip())
    flush()
    return "\n".join(out)


def page(path: pathlib.Path, title: str, description: str, body: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(PAGE.format(title=html.escape(title), description=html.escape(description),
                                app=html.escape(APP), body=body))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "app-ads.txt").write_text(APP_ADS)
    page(OUT / "privacy" / "index.html", f"Privacy Policy · {APP}",
         f"How {APP} handles your information.", markdown((ROOT / "privacy-policy.md").read_text()))
    page(OUT / "terms" / "index.html", f"Terms of Use · {APP}",
         f"Terms of Use for {APP}.", markdown((ROOT / "terms-of-use.md").read_text()))
    page(OUT / "index.html", APP, "BMI, workouts, food and daily health tracking. Your data stays on your phone.", f"""
<h1>{html.escape(APP)}</h1>
<p>BMI, body measurements, gym and home workouts with animated exercise guides,
calories and macros, steps, sleep and recovery: all in one app, in English and Urdu.
Your health data stays on your phone.</p>
<ul>
<li><a href="/privacy">Privacy Policy</a></li>
<li><a href="/terms">Terms of Use</a></li>
<li>Support: <a href="mailto:kamraniqbal.bcs062@gmail.com">kamraniqbal.bcs062@gmail.com</a></li>
</ul>""")
    for f in sorted(OUT.rglob("*")):
        if f.is_file():
            print(" ", f.relative_to(ROOT))


if __name__ == "__main__":
    main()
