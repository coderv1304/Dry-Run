"""Builds the static Dry Run landing pages from landing/content.json.

Every user visible string comes from content.json; this file only holds markup
and structure. `--check` fails when a generated page is out of date, so the
committed HTML can never drift from the copy source.
"""

from __future__ import annotations

import html
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LANDING = ROOT / "landing"
CONTENT = LANDING / "content.json"

PAGES = ("index.html", "privacy.html", "terms.html", "404.html")


def esc(value: str) -> str:
    return html.escape(value, quote=True)


def head(content: dict, *, title: str, description: str, page: str) -> str:
    site = content["site"]
    image = site["og_image"]
    return f"""  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light dark">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(description)}">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="{esc(site["name"])}">
  <meta property="og:title" content="{esc(site["og_title"])}">
  <meta property="og:description" content="{esc(site["og_description"])}">
  <meta property="og:image" content="{esc(image)}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{esc(site["og_title"])}">
  <meta name="twitter:description" content="{esc(site["og_description"])}">
  <meta name="twitter:image" content="{esc(image)}">
  <link rel="icon" href="favicon.ico" sizes="any">
  <link rel="apple-touch-icon" href="apple-touch-icon.png">
  <link rel="preload" href="fonts/poppins-latin-600.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="fonts/poppins-latin-400.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="stylesheet" href="tokens.css">
  <link rel="stylesheet" href="hero.css">
  <link rel="stylesheet" href="styles.css">
  <meta name="dry-run-page" content="{esc(page)}">"""


def skip_link(content: dict) -> str:
    return f'  <a class="skip-link" href="#main">{esc(content["site"]["skip_link"])}</a>'


def site_header(content: dict, *, home: str, anchor_prefix: str) -> str:
    entries = []
    for link in content["nav"]["links"]:
        href = esc(anchor_prefix + link["href"])
        label = esc(link["label"])
        entries.append(
            '\n          <li><a class="nav-link body-5" href="%s">%s</a></li>'
            % (href, label)
        )
    links = "".join(entries)
    return f"""  <header class="site-head">
    <div class="container head-inner">
      <a class="brand title-2" href="{esc(home)}">{esc(content["site"]["name"])}</a>
      <nav class="site-nav" aria-label="{esc(content["nav"]["label"])}">
        <ul class="nav-links">{links}
        </ul>
      </nav>
    </div>
  </header>"""


def site_footer(content: dict, *, prefix: str) -> str:
    footer = content["footer"]
    return f"""  <footer class="site-foot">
    <div class="container foot-inner">
      <p class="body-6 foot-notice">{esc(footer["notice"])}</p>
      <nav class="foot-links" aria-label="Legal">
        <a class="nav-link body-6" href="{esc(prefix + "privacy.html")}">{esc(footer["privacy_link"])}</a>
        <a class="nav-link body-6" href="{esc(prefix + "terms.html")}">{esc(footer["terms_link"])}</a>
      </nav>
      <p class="caption-2 foot-tagline">{esc(footer["tagline"])}</p>
    </div>
  </footer>"""


def page_shell(
    content: dict,
    *,
    title: str,
    description: str,
    page: str,
    body: str,
    prefix: str,
) -> str:
    return f"""<!DOCTYPE html>
<html lang="{esc(content["site"]["lang"])}">
<head>
{head(content, title=title, description=description, page=page)}
</head>
<body>
{skip_link(content)}
{site_header(content, home=prefix + "index.html", anchor_prefix=prefix)}
{body}
{site_footer(content, prefix=prefix)}
  <script src="{prefix}app.js" defer></script>
</body>
</html>
"""


def numbered_rows(items: list[dict]) -> str:
    rows = []
    for index, item in enumerate(items, start=1):
        rows.append(
            f"""          <li class="row">
            <span class="row-num caption-1" aria-hidden="true">{index}</span>
            <div class="row-body">
              <h3 class="title-3 row-title">{esc(item["title"])}</h3>
              <p class="body-3 row-text">{esc(item["body"])}</p>
            </div>
          </li>"""
        )
    return "\n".join(rows)


def tagline(content: dict) -> str:
    lines = []
    for line in content["tagline"]["lines"]:
        words = " ".join(
            f'<span class="word">{esc(word)}</span>' for word in line.split(" ")
        )
        lines.append(f'        <span class="tagline-line">{words}</span>')
    return (
        '  <section class="section tagline-section" aria-label="'
        + esc(content["tagline"]["aria_label"])
        + '">\n    <div class="container">\n      <h2 class="heading-2 tagline">\n'
        + "\n".join(lines)
        + "\n      </h2>\n    </div>\n  </section>"
    )


def index_page(content: dict) -> str:
    hero = content["hero"]
    site = content["site"]
    headline = "<br>\n        ".join(esc(line) for line in hero["headline_lines"])
    benefits = content["benefits"]
    how = content["how"]
    truth = content["truth"]
    risk = content["risk"]
    faq = content["faq"]
    final = content["final"]

    def bullet_list(items: list[str]) -> str:
        return "\n".join(
            f'            <li class="body-3 plain-item">{esc(item)}</li>'
            for item in items
        )

    faq_items = "\n".join(
        f"""        <details class="faq-item">
          <summary class="title-3 faq-question">{esc(item["question"])}</summary>
          <p class="body-3 faq-answer">{esc(item["answer"])}</p>
        </details>"""
        for item in faq["items"]
    )

    risk_rows = "\n".join(
        f"""          <li class="row">
            <div class="row-body">
              <h3 class="title-3 row-title">{esc(item["title"])}</h3>
              <p class="body-3 row-text">{esc(item["body"])}</p>
            </div>
          </li>"""
        for item in risk["items"]
    )

    body = f"""  <main id="main" tabindex="-1">
    <section class="section hero" aria-labelledby="hero-title">
      <div class="container">
        <h1 class="heading-1 hero-heading" id="hero-title">{headline}</h1>
        <p class="body-2 hero-sub">{esc(hero["subheadline"])}</p>
        <p class="hero-actions">
          <a class="btn btn-primary button-md" href="{esc(site["app_try_href"])}"
            >{esc(hero["primary_cta"])}</a>
          <a class="text-link body-5" href="#how-it-works">{esc(hero["secondary_cta"])}</a>
        </p>
        <aside class="notice" aria-label="Practice drill notice">
          <span class="notice-badge caption-3">{esc(content["notice"]["badge"])}</span>
          <span class="body-6 notice-text">{esc(content["notice"]["text"])}</span>
        </aside>
      </div>
    </section>

{tagline(content)}

    <section class="section" id="benefits" aria-labelledby="benefits-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="benefits-title">{esc(benefits["title"])}</h2>
        <p class="body-3 section-lead">{esc(benefits["lead"])}</p>
        <ol class="rows">
{numbered_rows(benefits["items"])}
        </ol>
      </div>
    </section>

    <section class="section" id="how-it-works" aria-labelledby="how-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="how-title">{esc(how["title"])}</h2>
        <ol class="rows">
{numbered_rows(how["steps"])}
        </ol>
      </div>
    </section>

    <section class="section" id="truth" aria-labelledby="truth-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="truth-title">{esc(truth["title"])}</h2>
        <div class="truth-grid">
          <div>
            <h3 class="title-3 truth-heading">{esc(truth["is_title"])}</h3>
            <ul class="plain">
{bullet_list(truth["is"])}
            </ul>
          </div>
          <div>
            <h3 class="title-3 truth-heading">{esc(truth["is_not_title"])}</h3>
            <ul class="plain">
{bullet_list(truth["is_not"])}
            </ul>
          </div>
        </div>
      </div>
    </section>

    <section class="section" id="risk" aria-labelledby="risk-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="risk-title">{esc(risk["title"])}</h2>
        <ul class="rows">
{risk_rows}
        </ul>
      </div>
    </section>

    <section class="section" id="faq" aria-labelledby="faq-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="faq-title">{esc(faq["title"])}</h2>
        <div class="faq">
{faq_items}
        </div>
      </div>
    </section>

    <section class="section final" aria-labelledby="final-title">
      <div class="container">
        <h2 class="heading-3 section-title" id="final-title">{esc(final["title"])}</h2>
        <p class="body-3 section-lead">{esc(final["body"])}</p>
        <p class="hero-actions">
          <a class="btn btn-primary button-md" href="{esc(site["app_try_href"])}"
            >{esc(final["cta"])}</a>
        </p>
      </div>
    </section>
  </main>"""

    return page_shell(
        content,
        title=site["title"],
        description=site["description"],
        page="index",
        body=body,
        prefix="",
    )


def legal_page(content: dict, key: str) -> str:
    doc = content[key]
    sections = "\n".join(
        f"""          <section class="legal-block" aria-labelledby="{key}-{index}">
            <h2 class="title-1 legal-heading" id="{key}-{index}">{esc(item["heading"])}</h2>
            <p class="body-3 legal-text">{esc(item["body"])}</p>
          </section>"""
        for index, item in enumerate(doc["sections"], start=1)
    )
    body = f"""  <main id="main" tabindex="-1">
    <section class="section legal" aria-labelledby="legal-title">
      <div class="container narrow">
        <h1 class="heading-3" id="legal-title">{esc(doc["title"])}</h1>
        <p class="caption-2 legal-updated">{esc(doc["updated"])}</p>
{sections}
        <p class="legal-back">
          <a class="text-link body-5" href="index.html">{esc(content["site"]["name"])}</a>
        </p>
      </div>
    </section>
  </main>"""
    return page_shell(
        content,
        title=f'{doc["title"]} | {content["site"]["name"]}',
        description=content["site"]["description"],
        page=key,
        body=body,
        prefix="",
    )


def not_found_page(content: dict) -> str:
    doc = content["not_found"]
    body = f"""  <main id="main" tabindex="-1">
    <section class="section not-found" aria-labelledby="not-found-title">
      <div class="container narrow">
        <p class="caption-1 not-found-mark">404</p>
        <h1 class="heading-3" id="not-found-title">{esc(doc["title"])}</h1>
        <p class="body-3 section-lead">{esc(doc["body"])}</p>
        <p class="hero-actions">
          <a class="btn btn-primary button-md" href="{esc(doc["href"])}">{esc(doc["cta"])}</a>
        </p>
      </div>
    </section>
  </main>"""
    return page_shell(
        content,
        title=f'{doc["title"]} | {content["site"]["name"]}',
        description=content["site"]["description"],
        page="404",
        body=body,
        prefix="",
    )


def render() -> dict[str, str]:
    content = json.loads(CONTENT.read_text(encoding="utf-8"))
    return {
        "index.html": index_page(content),
        "privacy.html": legal_page(content, "privacy"),
        "terms.html": legal_page(content, "terms"),
        "404.html": not_found_page(content),
    }


def main(argv: list[str]) -> int:
    check = "--check" in argv
    stale: list[str] = []
    for name, markup in render().items():
        path = LANDING / name
        if check:
            current = path.read_text(encoding="utf-8") if path.exists() else ""
            if current != markup:
                stale.append(name)
            continue
        path.write_text(markup, encoding="utf-8")
        print(f"wrote landing/{name}")
    if check:
        if stale:
            print("landing pages are stale, run python tool/build_landing.py:")
            for name in stale:
                print("  landing/" + name)
            return 1
        print("LANDING BUILD CHECK PASSED: pages match content.json")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
