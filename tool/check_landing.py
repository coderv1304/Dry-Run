"""Static checks for the built landing pages.

Covers the gate 4b acceptance list that can be checked without a browser:
copy comes only from content.json, no placeholder text, one primary action,
semantic landmarks, required metadata, self hosted assets only, the headers
CSP, the tagline reveal wiring and the absence of a proof section.
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LANDING = ROOT / "landing"
PAGES = ("index.html", "privacy.html", "terms.html", "404.html")
PLACEHOLDER_WORDS = ("lorem", "ipsum", "your headline here", "todo", "tbd", "placeholder")
PRIMARY_CTA = "Try a 90 second drill"

violations: list[str] = []


def fail(path: str, message: str) -> None:
    violations.append(f"{path}: {message}")


def read(name: str) -> str:
    return (LANDING / name).read_text(encoding="utf-8")


def check_common(name: str, text: str) -> None:
    if not text.startswith("<!DOCTYPE html>"):
        fail(name, "missing doctype")
    if 'lang="en"' not in text:
        fail(name, "missing lang attribute")
    if '<a class="skip-link" href="#main">' not in text:
        fail(name, "missing skip link to #main")
    if '<main id="main"' not in text:
        fail(name, "missing main landmark")
    if text.count("<h1") != 1:
        fail(name, "expected exactly one h1, found %d" % text.count("<h1"))
    if "<header" not in text or "<footer" not in text:
        fail(name, "missing header or footer landmark")
    if not re.search(r'<meta name="description" content="[^"]{40,170}"', text):
        fail(name, "meta description missing or outside 40 to 170 characters")
    for prop in ("og:title", "og:description", "og:image"):
        if f'property="{prop}"' not in text:
            fail(name, f"missing {prop}")
    if 'rel="icon"' not in text or 'rel="apple-touch-icon"' not in text:
        fail(name, "missing favicon or apple touch icon link")
    if "{{" in text or "}}" in text:
        fail(name, "unresolved template braces")
    if "<!--copy:" in text:
        fail(name, "unresolved copy marker")
    lowered = text.lower()
    for word in PLACEHOLDER_WORDS:
        if word in lowered:
            fail(name, f"placeholder text {word!r}")
    if "://" in text:
        fail(name, "external or absolute URL present; every asset must be self hosted")
    if re.search(r"\son[a-z]+=", text):
        fail(name, "inline event handler present; CSP allows no inline script")
    if "<style" in lowered:
        fail(name, "inline style block present; styles live in the stylesheets")
    if "\u2014" in text or "\u2013" in text:
        fail(name, "em or en dash present")
    for heading in re.findall(r"<h[1-3][^>]*>(.*?)</h[1-3]>", text, re.S):
        plain = re.sub(r"<[^>]+>", "", heading).strip()
        if plain.endswith("."):
            fail(name, f"heading ends with a period: {plain!r}")
    for ref in re.findall(r'(?:href|src)="([^"#][^"]*)"', text):
        if ref.startswith(("mailto:", "tel:", "#", "/")):
            continue
        target = (LANDING / ref).resolve()
        if not str(target).startswith(str(LANDING.resolve())):
            fail(name, f"reference escapes landing/: {ref}")
        elif not target.exists():
            fail(name, f"missing referenced file: {ref}")


def check_index(text: str, content: dict) -> None:
    anchors = re.findall(r'<a[^>]*href="([^"]*)"[^>]*>\s*([^<]*?)\s*</a>', text, re.S)
    primary = [href for href, label in anchors if label == PRIMARY_CTA]
    if PRIMARY_CTA not in text:
        fail("index.html", "primary action text missing")
    if primary != ["/try", "/try"]:
        fail("index.html", f"primary action must link to /try twice, found {primary}")
    if content["site"]["app_try_href"] != "/try":
        fail("content.json", "app_try_href must be /try")
    if not re.search(r'<a class="text-link body-5" href="#how-it-works">How it works</a>', text):
        fail("index.html", "secondary text link to How it works missing")
    if "id=\"proof\"" in text or "statistic" in text.lower() or "%" in text:
        fail("index.html", "proof or statistic rendered without a verified fact")
    if '<section class="section hero"' not in text:
        fail("index.html", "hero section missing")
    if "id=\"how-it-works\"" not in text or "id=\"faq\"" not in text:
        fail("index.html", "how it works or faq section missing")
    if '<ol class="rows">' not in text:
        fail("index.html", "numbered rows missing")
    if text.count('<li class="row">') < 7:
        fail("index.html", "expected benefit, step and risk rows")
    questions = re.findall(r"<details class=\"faq-item\">\s*<summary[^>]*>([^<]+)</summary>", text)
    if not 6 <= len(questions) <= 12:
        fail("index.html", f"faq needs 6 to 12 questions, found {len(questions)}")
    for phrase in ("Nothing real is needed", "Stop any time", "Delete when you like"):
        if phrase not in text:
            fail("index.html", f"risk reversal line missing: {phrase}")
    if "What this is and is not" not in text:
        fail("index.html", "honest is and is not block missing")
    if "Practice, not protection." not in text:
        fail("index.html", "footer tagline missing")
    if 'href="privacy.html"' not in text or 'href="terms.html"' not in text:
        fail("index.html", "privacy or terms link missing from the footer")
    words = re.findall(r'<span class="word">([^<]+)</span>', text)
    lines = text.count('<span class="tagline-line">')
    if lines < 2 or len(words) < 8:
        fail("index.html", "tagline reveal needs at least two lines of words")


def check_assets() -> None:
    headers = read("_headers")
    policy = re.search(r"Content-Security-Policy: (.+)", headers)
    if not policy:
        fail("_headers", "missing Content-Security-Policy")
        return
    value = policy.group(1)
    if "default-src 'self'" not in value:
        fail("_headers", "CSP must start from default-src 'self'")
    if "unsafe-inline" in value or "unsafe-eval" in value:
        fail("_headers", "CSP allows inline or eval")
    if re.search(r"https?://", value):
        fail("_headers", "CSP names a third party origin")
    for header in ("X-Content-Type-Options", "Referrer-Policy", "Permissions-Policy"):
        if header not in headers:
            fail("_headers", f"missing {header}")
    script = read("app.js")
    for needle in ("IntersectionObserver", "prefers-reduced-motion", "is-on"):
        if needle not in script:
            fail("app.js", f"tagline reveal missing {needle}")
    hero = read("hero.css")
    if "max-width: var(--content-max)" not in hero:
        fail("hero.css", "hero heading must cap at the content width")
    styles = read("styles.css")
    for needle in (".tagline.reveal-armed .word", "prefers-reduced-motion", "max-width: var(--content-max)"):
        if needle not in styles:
            fail("styles.css", f"missing {needle}")
    if (LANDING / "fonts").glob("*.woff2") and "font-display: swap" not in read("tokens.css"):
        fail("tokens.css", "webfonts must use font-display swap")
    og = LANDING / "og-image.png"
    if not og.exists():
        fail("landing", "og-image.png missing; run python tool/make_og_image.py")


def main() -> int:
    content_text = read("content.json")
    content = json.loads(content_text)
    for page in PAGES:
        if not (LANDING / page).exists():
            fail(page, "page missing; run python tool/build_landing.py")
            continue
        text = read(page)
        check_common(page, text)
        if page == "index.html":
            check_index(text, content)
        if page == "404.html" and 'href="index.html"' not in text:
            fail(page, "not found page must link back to the start")
    check_assets()
    body = json.dumps(content, ensure_ascii=False)
    if "\u2014" in body or "\u2013" in body:
        fail("content.json", "em or en dash present")
    if "%" in body:
        fail("content.json", "a percentage claim needs a verified fact")
    for word in PLACEHOLDER_WORDS:
        if word in body.lower():
            fail("content.json", f"placeholder text {word!r}")

    if violations:
        print("LANDING CHECK FAILED")
        for violation in violations:
            print("  " + violation)
        return 1
    print("LANDING CHECK PASSED: 4 pages, copy from content.json, self hosted only")
    return 0


if __name__ == "__main__":
    sys.exit(main())
