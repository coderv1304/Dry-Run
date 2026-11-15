# Plan 4b: the landing page

Intake assumption: a judge or a worried family member arrives from a direct link or a search, on a phone, and has about one minute.

## Page outline

1. Skip link, header with the brand and two anchors.
2. Hero: heading, subheading, one primary action (Try a 90 second drill) and a text link to How it works.
3. Drill notice, beside the hero.
4. Tagline reveal, two lines of words activating on scroll.
5. What one drill leaves you with, four numbered rows.
6. How it works, three numbered rows.
7. What this is and is not.
8. Nothing real is needed, three rows of reassurance.
9. Questions people ask, ten plain question and answer pairs.
10. Closing action, then the footer with the drill notice and legal links.

## Decisions

- Layout A, a classic hero plus sections. One audience, one action, nothing to compare.
- No proof section: `docs/FACTS.md` has no row with `verified_by_human: true`.
- Copy is generated into the HTML from `landing/content.json` by `tool/build_landing.py`, so the page renders without JavaScript and stays a single source of copy.
- Primary action points at `/try` on the app's own origin, so the drill is one tap from the hero.
- Reveal starts from the tertiary text token rather than 30% opacity, to keep contrast passing while the words activate.
- Home is Cloudflare Pages, so the headers file is `landing/_headers` with `default-src 'self'` and no third party sources.

## Verification

`make gate-4b`: lint-ui, landing build check, landing structure check, brand image check, Lighthouse record in `docs/PERF.md`.
