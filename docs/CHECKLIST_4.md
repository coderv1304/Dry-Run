# Skill Checklists, Gate 4

Both `docs/design/figma-designer.md` and `docs/design/landing-page-design.md` were run against the
product screens this gate polished. `BANNED_UI.md` overrides both. Legend: **Pass** verified in the
repo, **Adapted** satisfied in Flutter rather than a Figma canvas, **Logged** deliberate deviation
recorded in `docs/DECISIONS.md` or `docs/design/DESIGN_DECISIONS.md`.

## figma-designer checklist

| Item | Result | Evidence |
| :--- | :--- | :--- |
| Every text layer uses a named text style on the Tailwind scale | Pass | The last off token Material styles in about, consent, debrief, join and report now read `DrTypeTheme`; `make lint-ui` and a grep for `Theme.of(context).textTheme` find none. |
| Every padding and gap bound to a spacing variable | Pass | New call strip and reveal use `DrSpace` and `DrSize` only; design lint passes. |
| Every radius bound to a radius variable, nested radii follow the formula | Pass | `DrRadius.r4` badge inside `DrRadius.r12` card, both tokens. |
| Every fill and stroke bound to a Color System token, both modes work | Pass | `surfaceSecondary`, `borderPrimary`, `surfaceInfoSubtle`, `borderAction`, `actionPrimary`; screenshots in both modes. |
| Core palettes have at least 10 shades; Color System tokens are aliases | Pass | Unchanged from gate 2, asserted by test. |
| A Foundations frame shows every token and text style with bound samples | Adapted | The gallery gained a Call status section; the canvas grew to 6100 to fit it. |
| Contrast passes 4.5:1 body, 3:1 large text and UI parts | Pass | `tool/contrast_check.py`, 224 pairings, both modes. |
| No background gradients, no single side borders, no italics | Pass | The call strip is a full border; the only gradient remains the hero heading text. |
| Hero heading and subheading capped at 680, no periods, no eyebrow tag | Pass | Home heading unchanged; `DrSize.contentMax`. |
| Interactive components have every state; buttons have 5 types x 5 states | Pass | Unchanged; the new components are not interactive, and pressed and focus states stay on `DrButton`. |
| Icons from Phosphor, Solar or Iconamoon at one stroke weight | Pass | Only `DrIcons`; no new icon was added. |
| No placeholder copy, no layer named `Frame` or `Group` | Pass | New copy is reviewed English and Hindi. |

## landing-page-design quick checklist

| Item | Result | Evidence |
| :--- | :--- | :--- |
| One offer, one audience, one primary action | Pass | Each screen keeps one primary control; the debrief keeps share as secondary. |
| No competing CTAs above the fold | Pass | Drill header has one secondary End drill beside the title. |
| Specific numbers instead of vague verbs | Pass | Turn count and confidence are real values from the engine. |
| At least one risk reversal | Logged | No purchase exists, so the disclaimer carries the risk reversal. |
| Proof sits next to the claim it supports | Logged | No testimonials are permitted and no verified statistic exists. |
| Layout type chosen deliberately | Pass | Single column at 390, two column only where the content earns it. |
| Single approved typeface, no italics, no ultra bold | Pass | Poppins only, linted. |
| No hyphens in copy, no orphaned words | Pass | New compliance sentence has no hyphens; both locales reflow at 200 percent. |
| Every font size on a Tailwind step | Pass | `DrTypeTheme` only. |
| Every text element uses a named text style | Pass | Same fix as the Figma checklist row. |
| Every spacing value from the spacing table | Logged | 19 value scale, the deviation recorded at gate 2 and unchanged. |
| Nested radii follow the formula | Pass | Badge radius 4 inside card radius 12. |
| No single sided card borders, no background gradients | Pass | Full borders only. |
| Hero heading and subheading capped at 680 with meaningful breaks | Pass | Unchanged. |
| Icons from Phosphor, Solar or Iconamoon | Pass | Unchanged. |
| Every transition uses the base curve; reveals use IntersectionObserver | Pass | Drift to Flutter: `DrRevealGroup` runs one controller on `DrMotion.curve`; no hover motion exists. |
| Tagline reveal section present, words activating on scroll | Logged | Still owned by Prompt 5, which builds the landing motion. |
| No invented prices, stats or testimonials | Pass | None added. |
| Checked at 390 px with no overflow | Pass | Six screens at 390 in both modes, plus Hindi at 200 percent with zero overflow asserted in test. |
| Real draft copy, no banned filler | Pass | Lint bans filler and placeholder Latin. |
| Hover, active, focus, loading, empty and error states present | Pass | Skeletons, empty views, inline errors and static hover unchanged; error dialogs are confirmations only, never error reports. |
| No dead links, current nav item indicated | Pass | Route table unchanged. |
| 404, legal links, form validation, favicon, meta tags, alt text | Logged | Landing work owned by Prompt 5; app metadata already branded. |
