# Skill Checklists, Gate 2

Both `docs/design/figma-designer.md` and `docs/design/landing-page-design.md` checklists were run
against the delivered system. `BANNED_UI.md` overrides both. Legend: **Pass** verified here,
**Adapted** satisfied in code instead of a Figma canvas, **Logged** deliberate deviation recorded in
`docs/design/DESIGN_DECISIONS.md`.

## figma-designer checklist

| Item | Result | Evidence |
| :--- | :--- | :--- |
| Every text layer uses a named text style on the Tailwind scale | Pass | 26 styles generated; `DrTypeTheme` getters; gallery specimen; test asserts every size is on the scale. |
| Every padding and gap bound to a spacing variable | Pass | `DrSpace` only; lint fails literals; gallery spacing bars. |
| Every radius bound to a radius variable, nested radii follow the formula | Pass | `DrRadius`; `DrRadius.nested` unit tested. |
| Every fill and stroke bound to a Color System token, both modes work | Pass | Components read `DrColors`; lint bans raw colours; goldens in both modes. |
| Core palettes have at least 10 shades; Color System tokens are aliases | Pass | 21 to 22 shades per palette; validator resolves every alias. |
| A Foundations frame shows every token and text style with bound samples | Adapted | The design gallery is the Foundations surface: every palette shade, every semantic token in both modes, spacing, radius, type, motion, touch. |
| Contrast passes 4.5:1 body, 3:1 large text and UI parts | Pass | `tool/contrast_check.py`, 224 pairings, both modes, zero failures. |
| No background gradients, no single side borders, no italics | Pass | Gradient allowlist is the hero file only; lint bans one sided borders and italics. |
| Hero heading and subheading capped at 680, no periods, no eyebrow tag | Pass | `DrSize.contentMax`, `--content-max`; hero copy has no periods and there is no eyebrow element. |
| Interactive components have every state; buttons have 5 types x 5 states | Pass | `DrState`, `DrFieldState`, 25 button combinations in the gallery and golden. |
| Icons from Phosphor, Solar or Iconamoon at one stroke weight | Pass | Vendored Phosphor, one family, flattened and painted by `DrIcon`. |
| No placeholder copy, no layer named `Frame` or `Group` | Pass | Copy is real draft copy; widget names are role based. |

## landing-page-design quick checklist

| Item | Result | Evidence |
| :--- | :--- | :--- |
| One offer, one audience, one primary action | Pass | One drill for one family member, one primary CTA, the invite CTA is secondary. |
| No competing CTAs above the fold | Pass | Single primary button plus one clearly secondary action. |
| Specific numbers instead of vague verbs | Pass | No numbers shipped at all: no verified fact exists yet, so no statistic section. |
| At least one risk reversal | Logged | The drill is a practice tool with no purchase, so no commercial risk reversal applies; the disclaimer states limits explicitly. |
| Proof sits next to the claim it supports | Logged | No testimonials or logos are allowed, and no verified statistic exists, so proof is absent by design. |
| Layout type chosen deliberately | Pass | Classic hero plus sections, chosen because the drill explains itself in three steps. |
| Single approved typeface, no italics, no ultra bold | Pass | Poppins 400 to 700, lint enforced. |
| No hyphens in copy, no orphaned words | Pass | Copy rewritten without hyphens; headings break at meaningful points. |
| Every font size on a Tailwind step | Pass | Generated utilities; lint fails off scale sizes. |
| Every text element uses a named text style | Pass | `heading-*`, `title-*`, `body-*`, `button-*`, `caption-*` classes in generated CSS. |
| Every spacing value from the spacing table | Logged | 19 value scale, deviation documented and justified in DESIGN_DECISIONS section 4. |
| Nested radii follow the formula | Pass | One radius rule, unit tested. |
| No single sided card borders, no background gradients | Pass | All around borders and rule elements; hero gradient is text only. |
| Hero heading and subheading capped at 680 with meaningful breaks | Pass | `--content-max` plus a hand broken headline. |
| Icons from Phosphor, Solar or Iconamoon | Pass | Only vendored Phosphor icons are referenced. |
| Every transition uses the base curve; reveals use IntersectionObserver | Pass | No hover transitions exist at all; the one permitted animated property is press scale in Flutter. |
| Tagline reveal section present, words activating on scroll | Logged | Deferred to Prompt 5, which owns the landing page's motion build. No motion is shipped in this gate, so nothing contradicts the rule. |
| No invented prices, stats or testimonials | Pass | The unverified statistic was removed; `content.json` carries no numbers. |
| Checked at 390 px with no overflow | Logged | Human visual pass listed in `docs/HUMAN_TODO.md`; the layout uses wrapping flex and single column sections. |
| Real draft copy, no banned filler | Pass | Lint bans the filler list and placeholder Latin. |
| Hover, active, focus, loading, empty and error states present | Pass | Components ship every state; the landing styles define hover and focus visible. |
| No dead links, current nav item indicated | Pass | Navigation points at in page sections; `aria-current` styling is defined. |
| 404, legal links, form validation, favicon, meta tags, alt text | Logged | Favicon and meta description are done; the 404 page, legal pages and any form belong to Prompt 5's landing build. |
