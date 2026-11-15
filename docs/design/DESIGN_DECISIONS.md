# Design Decisions (Gate 2)

Authority order: `docs/design/BANNED_UI.md` binds and overrides both skill files; where the two
skills disagree with each other the stricter rule wins; Prompt 2 overrides a skill default wherever
it names a concrete value. Every decision below is enforced by a tool, a test or both.

## 1. One source, generated code

- `design/tokens.json` is the only file where a design value exists.
- `tool/gen_tokens.py` emits `app/lib/design/color_tokens.g.dart`, `space_tokens.g.dart`,
  `type_tokens.g.dart` and `landing/tokens.css`. Every output carries a generated header.
  `--check` re-renders in memory and fails if a file on disk differs, which proves idempotence.
- `tool/gen_icons.py` flattens the vendored Phosphor SVGs into `app/lib/design/icons.g.dart`, so the
  app paints real Phosphor geometry without an icon font or a runtime SVG dependency.
- `tool/gen_brand_assets.py` renders the favicon, web icons and Android launcher icons from palette
  colours, replacing every recorded default asset.
- `make design-tokens`, `make design-assets`, `make goldens` are the only writers. `make lint-ui`
  fails when a generated file is stale.

## 2. Typography

| Rule | Application |
| :--- | :--- |
| One typeface | Poppins, weights 400, 500, 600, 700 only. Bundled in `app/assets/fonts` and `landing/fonts`, declared in `pubspec.yaml` and `@font-face`. |
| No runtime font fetching | Removed the Google Fonts import from the landing page; no font package, no remote CSS, no `fetch` of font files. Landing uses local `woff2`, the app bundles `ttf`. |
| Banned families | Geist, Geist Mono, Inter, Roboto, Arial, Helvetica, Open Sans. Banned by `BANNED_UI` 9 and by Prompt 2; the lint fails on any of them in a font declaration. |
| Override Roboto | `ThemeData(fontFamily: 'Poppins', fontFamilyFallback: ['Noto Sans Devanagari'])` plus Poppins on every component theme text style (app bar, dialog, snack bar, list tile, chip, input, tooltip, tab bar, navigation bar, bottom navigation bar). A test asserts 18 text slots. |
| Weights | Heading 1 to 6 Semibold 600. Title 1 to 5 Medium 500. Body 1/2/3 = 600/500/400, Body 4/5/6 = 600/500/400. Button 600. Caption 600/500/400. Nothing above 700, no italics. |
| Devanagari coverage | Verified by parsing the `cmap` of all four Poppins weights for U+0905, 0915, 0916, 0937, 094D, 0964, 0966 (`tool/font_coverage_check.py`). |
| Glyph fallback | Noto Sans Devanagari is bundled and declared only in `fontFamilyFallback`. It is never a primary family. |

**Devanagari leading exception (deliberate).** Hindi line height is `round(latin line height x 1.2)`
snapped to the nearest spacing token, ties upward. On the 19 step scale the realised increase is
+16.7% to +28.6%, which is the closest achievable to "about 20 percent" without inventing off scale
leading. Values live in `design/tokens.json` under `typography.styles[].devanagariLineHeight`,
`gen_tokens.py` asserts each one against the rule, and `DrTypeTheme.devanagari` is selected per
locale by `drThemeData(devanagari: true)`.

## 3. Colour

- **Two layers.** `Core` holds eight palettes (Primary, Secondary, Accent, Grayscale, Red, Green,
  Yellow, plus the alpha overlay set), each with 21 to 22 shades. `semantic.light` and
  `semantic.dark` alias core shades only; every alias is resolved and validated at generation time.
- **One accent, restrained.** Primary 500 is `#39BFD0`: hue 186.8 (inside 160 to 210) and saturation
  72.6% (under 80). Secondary is a neutral slate. No purple, violet or indigo anywhere; the contrast
  tool asserts the hue and saturation window from the token file, so a future edit cannot drift out.
- **Dark backgrounds.** Only `#000000`, `#181818`, `#1F1F1F`, `#272727`, `#313131`, `#131209`. The
  validator fails if any dark `Surface/*` or `Action/Tertiary` resolves outside that list.
- **Overlays and scrims.** Transparency lives in the alpha layer (`Grayscale/1000` at 16, 24, 40, 64,
  80%) and `Overlay/*` aliases it. Dialog scrim, sheets and navigation use solid surface tokens plus
  an overlay token, never a blur: the lint fails on `BackdropFilter`, `ImageFilter.blur`,
  `MaskFilter.blur`, `backdrop-filter` and `filter: blur()`.
- **Gradients.** None, except the hero heading text (white to `#9B9B9B` on dark, black to `#666666`
  on light). `design/tokens.json` carries a two entry allowlist for this, and the lint permits
  gradient code only in `app/lib/design/components/dr_hero_heading.dart` and `landing/hero.css`.
- **Flat surfaces.** No dots, grids, noise, blobs or glows. Nothing in the system draws them; shadows
  are `Surface/Transparent` with elevation 0 in every theme, so no coloured shadow can appear.
- **Contrast.** `tool/contrast_check.py` checks 224 token pairings across both modes at 4.5:1 for
  body text and 3:1 for large text and UI parts, plus the two gradient stop sets measured at their
  lightest end. It fails the gate on any miss. Disabled text is deliberately held to the body ratio
  rather than exempted.

## 4. Spacing, radius, layout

- **Spacing scale:** 0, 2, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 56, 64, 72, 80, 96.
  This is the one deliberate deviation from the skills' 13 value table (which omits 20, 28, 36, 44,
  56 and 72). Reason: the Devanagari 20% leading rule needs a token to land on at small sizes, and
  44/56 touch targets plus the 56 elder control height have to be expressible. The lint derives the
  scale from `design/tokens.json`, so anything outside it is off scale and fails.
- **Radius:** 0, 2, 4, 6, 8, 12, 16, 24, full with the nested rule `inner = outer - gap`, applied only
  when the gap is under 32 and the result is above 2, snapped down to a radius token, otherwise
  square. Implemented once as `DrRadius.nested` and unit tested (16/8 gives 8, 12/2 gives 8, 4/4 gives
  0, a 32 gap leaves the outer radius alone).
- **Touch:** 44 minimum, 56 on elder facing screens; `DrTouch.minimum` and `.elder`, applied to
  buttons, inputs, list rows and the navigation bar.
- **Layout:** no bento grids, never three or more equal cards in a row at any breakpoint. Three
  benefits or steps render as a vertical numbered list (the landing uses an `<ol>`, the gallery stacks
  data views vertically in one column).
- **Measure:** hero heading and subheading cap at 680 (`DrSize.contentMax`), desktop container 1200.

## 5. Icons

- Vendored Phosphor only (`app/assets/icons`, MIT, one stroke weight family). Lucide, Material Icons
  and Material Symbols are banned by `BANNED_UI` 2 and Prompt 2, as are sparkle, star burst, magic
  wand and any "AI" glyph.
- The lint bans `Icons.`, Lucide, Material Symbols and the AI glyph names in source. The Material
  Icons font is not bundled (`uses-material-design: false`), so an accidental Material glyph fails
  loudly instead of shipping.
- Glyphs are flattened to contours at generation time and painted by `DrIcon`; sizes come from
  `DrSize` (16, 20, 24, 32).

## 6. Motion and interaction

- Curve `cubic-bezier(0.22, 1, 0.36, 1)`; 500 ms for layout, 300 ms for colour, 200 ms floor for
  anything that moves. `DrMotion` exposes all of it; the token validator enforces the floor.
- **Hover is an instant static colour swap on web pointers only.** `DrButton` and `DrListRow` read
  rest/hover/focus fills straight from tokens through `FocusableActionDetector`; there is no
  transition, transform, scale, shadow or animation in the hover path. Every built in Material button
  theme sets `animationDuration: Duration.zero`, a transparent overlay and `NoSplash`, with splash,
  highlight and hover colours set to `Surface/Transparent`. The lint fails any `:hover` rule that
  contains `transition`, `transform`, `animation`, `scale(` or `box-shadow`, and any Dart hover
  handler that starts an animation.
- **Touch press feedback** is `scale 0.98` over 200 ms on the base curve, via `AnimatedScale`. It is
  the only animated property in the system and the only implicit animation inside a component; tests
  assert the duration, the curve and that no `AnimatedContainer`, `AnimatedOpacity` or
  `DecoratedBoxTransition` exists inside `DrButton`.
- **Focus** is a static 2 px ring outside the control (outer radius 12, inner 8 by the nested rule),
  never a colour change alone.

## 7. Components

| Component | States |
| :--- | :--- |
| `DrButton` | Type Primary, Secondary, Tertiary, Error, Warning; State rest, hover, pressed, focus, disabled (25 combinations); sizes lg, md, sm, xsm; elder target. |
| `DrTextField` | rest, filled, focus, error, disabled. |
| `DrListRow` | rest, hover, focus, disabled, with an optional leading icon and a Phosphor chevron. |
| `DrTimelineRow` | complete, current, upcoming, with node, connector and trailing label. |
| `DrNodeLineDiagram` | done, active, pending nodes on a fixed connector grid. |
| `DrBanner` | the DRILL badge, warning and info variants, solid surface tokens, no blur. |
| `DrSkeleton`, `DrEmptyView`, `DrErrorView` | loading shaped like the real layout, a composed empty state, an inline specific error with retry. |
| `DrIcon`, `DrHeroHeading` | Phosphor glyphs; the single gradient exception. |

- Every component takes its copy from the caller; the only hardcoded strings are gallery specimens.
- Components consume tokens only: no raw colour, spacing, radius or font size (lint enforced).
- `stateOverride` is a preview hook that lets the gallery and the goldens render any state
  deterministically. It pins the existing state machine; it is not a second styling path.
- `DesignGallery` is the visual spec: every palette shade, every semantic token in both modes, spacing
  bars, radius samples, all 26 text styles, the Hindi leading specimen, motion and touch values, the
  25 button variants, every field state, rows, timeline, diagram, banner, data views, icons and the
  hero gradient.

## 8. Content and data

- No pricing, no tiers, no testimonials. The lint bans the words in app and landing copy.
- **Data sections render nothing without a verified fact.** `docs/FACTS.md` has no
  `verified_by_human: true` row, so the landing statistic section was removed rather than shipped
  unverified and `landing/content.json` carries no numbers. When a fact becomes verified the section
  returns with its source.
- Sentence case for headings and buttons, no em or en dashes, no emoji, no placeholder Latin, no
  filler phrases; the lint enforces these across ARB, landing files, scenario YAML and `app/web`.

## 9. Enforcement inventory

- `tool/gen_tokens.py --check`, `tool/gen_icons.py --check`: generated code is current.
- `tool/font_coverage_check.py`: Poppins Devanagari coverage, fallback present.
- `tool/contrast_check.py`: 224 pairings plus gradient stops.
- `tool/design_lint.py`: 20 rules over `app/lib`, `app/web`, `landing`, scenario YAML and ARB; never
  scans minified bundles, build output, docs, tooling or test fixtures.
- `tests/test_design_lint.py`: one deliberately bad fixture per rule plus a clean fixture, the
  gradient allowlist scoping, the token scale source, and emoji exclusion of digits and Devanagari.
- `app/test/design_system_test.dart` and `app/test/golden_test.dart`: theme overrides, static hover,
  press feedback, token invariants, and 18 goldens (8 components plus the gallery, both modes).

## 10. Conflicts and resolutions

| Conflict | Winner | Resolution |
| :--- | :--- | :--- |
| Skill B9: hover is a background shift or slight scale; skill B7: animate transforms | `BANNED_UI` 15 and Prompt 2 | Instant static colour swap only; a test asserts no animated hover widgets. |
| Skill B7: navigation over a background blur, mobile panel with strong blur | `BANNED_UI` 6 and Prompt 2 | Solid surface tokens plus overlay tokens, no blur anywhere. |
| Skill layout: "consider a bento layout" or an asymmetric grid | `BANNED_UI` 4 and 5, Prompt 2 | No bento; never three equal cards in a row; vertical numbered list for three items. |
| Skill fonts: Geist, Manrope, Poppins allowed | Prompt 2 and `BANNED_UI` 9 | Poppins only; Geist is banned outright. |
| Figma style table: headings Regular; landing table: headings Semibold | Prompt 2 | Semibold 600 for Heading 1 to 6. |
| Figma style table: hero gradient bound to variables, allowed on text | Prompt 2 | Kept as the one exception, text only, stops from generated gradient tokens. |
| Skill: never a single side border; the old landing had `border-bottom` | Both | All around borders only; separators are 1 px full width rule elements. |
| `BANNED_UI` 11: no em dashes "as a general habit"; skill copy style | Both, strictly | No em or en dashes at all in copy; lint enforces. |
| Skill B8: use `{{price}}` placeholders for missing facts | Prompt 2: data sections render nothing | No placeholders shipped; the section is absent. The lint still fails unresolved `{{`. |
| Material defaults: Roboto, ink splash, hover overlays, elevation | Prompt 2 | Overridden in `ThemeData` and every component theme; splash and hover colours transparent, animation duration zero. |
| Skills' 13 value spacing table | Prompt 2 "0 to 96 scale" plus the Devanagari rule | 19 value scale, logged above as the single deliberate deviation. |
| Web manifest requires literal colours | Prompt 2 token only rule | Two colours (`#181818`) are duplicated in `manifest.json` because the manifest format cannot read CSS variables; everything visible on the page uses generated variables. |

## 11. Gaps and deferred work

- ARB localisation plumbing arrives with Prompt 3 screens; this gate ships no feature copy, only
  gallery specimens and component parameters. The lint already enforces ARB rules.
- The landing page is verified by the lint and the contrast tool, not by a browser pass in this gate.
- Goldens are rasterised per platform and were generated on Windows; CI runs the design gate on
  `windows-latest`, and another OS needs `make goldens` there before it can compare.
- A 390 px visual pass of the landing page is human work, listed in `docs/HUMAN_TODO.md`.
## Gate 4 components

### S-22: `DrRevealGroup` is the only reveal in the app

- **Shape:** one `AnimationController` for the group, one interval per item, `FadeTransition` plus
  `SlideTransition` of `DrSpace.s8 / 100`, base curve, 500 ms, 50 ms overlap (D-022).
- **Reduced motion:** when `MediaQuery.disableAnimations` is true the controller starts at 1, so the
  content is simply present.
- **Where:** debrief timeline rows and the state path diagram through `DrNodeLineDiagram(reveal: true)`.
  Transforms never affect layout, so connector lines do not move.

### S-23: `DrCallStatus` replaces the plain drill banner

- **Shape:** full border card on `surfaceSecondary`, badge on `surfaceInfoSubtle` with `borderAction`,
  state label in `caption2`, practice sentence in `caption2` tertiary, waveform at the left.
- **Waveform:** static, 44 by 32, bars of `DrSize.strokeStrong` and token heights, colour by state
  (tertiary, secondary, action). Same height in every state, so the header never jumps.
- **Badge:** always present, in ringing, answering and live, because the drill must never look like a
  real agency call.

### S-24: The gallery canvas grew once

- The Call status specimen added about 250 px, so the fixed gallery canvas in `design_system_test.dart`
  and `golden_test.dart` grew from 5800 to 6100 and still asserts a layout with no overflow. No
  assertion was removed.
