# Web Performance

Measured on the built app in `app/build/web` on 2026-11-15. Everything below is
a real measurement from `tool/measure_web_perf.mjs`, not an estimate. Where the
app is over budget, this file says so and lists the mitigations that are in
place or queued.

## Budget

| Metric | Budget | Measured | Status |
| :--- | :--- | :--- | :--- |
| First interactive, Fast 3G, mid-tier mobile CPU | 5.0 s | 22.0 s | over by ~4.4x |
| First-load transfer, cold cache | 2.0 MiB | 3.58 MiB | over by ~1.8x |
| Build output on disk | 12 MiB | 42.04 MiB | over by ~3.5x |

The app is honest about being over budget. It is not a marketing site: the
drill is a Flutter CanvasKit app, and a correct number matters more than a
flattering one.

## Build size on disk

`flutter build web --release --no-web-resources-cdn --base-href /`

| Path | Size |
| :--- | ---: |
| `canvaskit/` (all engine variants and symbol maps) | 25.11 MiB |
| `canvaskit/chromium/` | 6.44 MiB |
| `canvaskit/webparagraph/` | 4.55 MiB |
| `main.dart.js` | 3.17 MiB |
| `assets/` (manifest, shaders, fallback font) | 1.29 MiB |
| `assets/assets/fonts/` (Poppins and Noto Sans Devanagari) | 1.22 MiB |
| `assets/fonts/fallback/Roboto-Regular.ttf` | 0.16 MiB |
| `assets/NOTICES` | 1.29 MiB |
| `icons/` + `favicon.png` | 0.08 MiB |
| **Total** | **42.04 MiB** |

The 25 MiB engine directory contains every renderer variant Flutter can emit
(`canvaskit`, `chromium`, `webparagraph`, `skwasm`, `skwasm_heavy`, `wimp`) plus
symbol maps. A browser only fetches `canvaskit/canvaskit.js` and
`canvaskit/canvaskit.wasm`, so the transfer size is much smaller than the
directory size. A real deploy should still prune the unused variants.

## First-load transfer, cold cache

Served by `tool/serve_web.mjs`, which applies the `_headers` rules and brotli
compression the way a production host would. Without compression the first load
is 9.8 MiB; with brotli it is 3.58 MiB.

| Resource | Raw | Brotli |
| :--- | ---: | ---: |
| `canvaskit/canvaskit.wasm` | 6.95 MiB | 2.15 MiB |
| `main.dart.js` | 3.13 MiB | 0.69 MiB |
| Poppins Regular/Medium/SemiBold/Bold | 0.61 MiB | 0.61 MiB (uncompressed TTF) |
| `canvaskit/canvaskit.js` | 0.08 MiB | 0.02 MiB |
| HTML, bootstrap, manifest, service worker | small | small |
| **Total transfer** | **9.8 MiB decoded** | **3.58 MiB** |

The engine wasm and the Dart bundle are the whole cost. The four Poppins
typefaces are fetched as raw TTF and are the largest remaining easy win.

## Throttled startup

Profile: Chrome, cold cache, Fast 3G network emulation (1.6 Mbps down, 750 Kbps
up, 150 ms round trip) and a 4x CPU slowdown to stand in for a mid-tier Android
phone. Median of five runs.

| Milestone | Time |
| :--- | ---: |
| First paint (branded loading shell) | 0.55 s |
| DOM content loaded | 0.40 s |
| **First Flutter frame** | **19.36 s** |
| **Home heading visible and interactive** | **22.03 s** |
| Transfer | 3.58 MiB |

The branded shell paints at 0.55 s, so a person sees the Dry Run mark, the
tagline, and "Loading the practice drill" instead of a white screen. The gap
from 0.55 s to 19.36 s is downloading and compiling the wasm engine and the Dart
bundle on a slow link and a slow CPU.

Unthrottled localhost, same app and same script, median of five runs: first
paint 0.42 s, first Flutter frame 1.22 s, home heading 1.57 s. The throttled
number is the honest one for a phone on mobile data.

## Mitigations in place

- Branded pre-Flutter loading state in `app/web/index.html` paints at first
  paint and is styled with tokens. The gap is never a blank screen.
- Engine files are self-hosted (`--no-web-resources-cdn`), so no third-party
  CDN latency or CSP exception is needed.
- `_headers` marks `canvaskit/*`, `assets/*`, `icons/*` and `favicon.png`
  `immutable` with a one-year cache, so a repeat visit skips the wasm download.
  `index.html`, `flutter_bootstrap.js`, `main.dart.js` and the service worker
  are `no-cache`, so a deploy is picked up immediately.
- Brotli/gzip for JS, wasm, HTML and CSS, with `Vary: Accept-Encoding`. This is
  what takes the first load from 9.8 MiB to 3.58 MiB.
- Copy is short, the first route is the home screen, and no network call blocks
  the first frame.
- App fonts are bundled and self-hosted, so text never flashes in a fallback
  face after first frame.

## Mitigations queued (not done in Prompt 3)

1. **Prune unused engine variants at deploy.** Copy only
   `canvaskit/canvaskit.js` and `canvaskit/canvaskit.wasm`. This cuts the deploy
   from 42.04 MiB to roughly 11 MiB and removes the symbol maps. Add a small
   `tool/prune_web.sh` step in the deploy path.
2. **Ship wasm + skwasm.** `--wasm` builds `skwasm.wasm` at 3.43 MiB instead of
   the 6.95 MiB CanvasKit wasm, with a CanvasKit fallback for old browsers. This
   is the largest single transfer win and needs a browser-support check before
   it becomes the default.
3. **Compress or subset the Poppins TTFs.** Convert to WOFF2 or subset to Latin
   plus the Devanagari range only when the Hindi locale is selected. Saves most
   of the 0.61 MiB of raw TTF.
4. **Serve the Devanagari face only for Hindi.** The 0.61 MiB variable font is
   loaded for every user today. Load it when the language is `hi`.
5. **Defer secondary routes.** `deferred as` imports for About and Report would
   shrink `main.dart.js`. The drill route stays in the main bundle so the
   practice call never waits on a lazy chunk.
6. **Preload the engine.** A `<link rel="preload">` for `canvaskit.wasm` and
   `main.dart.js` would start both downloads earlier and overlap them with the
   bootstrap script.
7. **Service worker caching.** The build emits a service worker, but the
   `flutter_bootstrap.js` entry does not yet register it aggressively for the
   engine files. Registering it would make the second visit near-instant.

## How to reproduce

```
make web
node tool/serve_web.mjs 8080 app/build/web
node tool/measure_web_perf.mjs http://127.0.0.1:8080/ 5
```

Set `DR_NO_THROTTLE=1` for the unthrottled baseline. Set `CHROME_PATH` if Chrome
is not at the default Windows path.

## Landing page, gate 4b

The static page in `landing/` is measured on its own, over loopback, with the
headers file that ships to the host (`landing/_headers`). Lighthouse 12.8.2,
mobile emulation, cold cache, 390 x 844, 2026-11-15.

| Category | Score |
| :--- | :--- |
| Performance | 100 |
| Accessibility | 100 |
| Best practices | 100 |
| SEO | 100 |

| Metric | Measured |
| :--- | :--- |
| First contentful paint | 1.4 s |
| Largest contentful paint | 1.5 s |
| Total blocking time | 0 ms |
| Cumulative layout shift | 0.011 |
| Speed index | 1.4 s |
| First load transfer | 77 KiB |

- Copy is pre-rendered into the HTML, so the heading, the three steps and the ten
  questions are readable before any script runs.
- The page loads three stylesheets, one deferred script and four self hosted
  WOFF2 faces; the two faces used above the fold are preloaded.
- No third party request is made. Fonts, icons and the share image come from the
  same origin, and `landing/_headers` declares `default-src 'self'`.
- Lighthouse found no failing accessibility audit, so contrast, names, roles and
  the landmark order all passed at runtime as well as in the token check.

### Width check at 390 px

Measured in Chrome at a 390 px wide viewport: `document.documentElement`
reported `scrollWidth` 374 and `clientWidth` 374, and no element reached past
either edge, so the page does not scroll sideways. The 374 figure is the
viewport minus its scrollbar.

### Tagline reveal check

The words activate on scroll and never rely on animation alone. A headless
render with a tall window showed all 15 words reach `is-on` through the
IntersectionObserver, and a render forced into reduced motion showed all 15
words on at once, with no transition.

### Reproduce

```
cd landing && python -m http.server 8099 --bind 127.0.0.1
node "$LIGHTHOUSE/cli/index.js" http://127.0.0.1:8099/index.html \
  --chrome-flags="--headless=new" \
  --only-categories=performance,accessibility,best-practices,seo
```
