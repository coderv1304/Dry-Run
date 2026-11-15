# Routes and Links

The app uses `go_router` with the path URL strategy, so every screen is a real
address on web. Tokens never appear in a path or a query string: they travel in
the URL fragment and are removed from the address bar before the first frame.

## Screens

| Path | Screen | Needs a token | Back target |
| :--- | :--- | :--- | :--- |
| `/` | Organizer home: create an invite, share it, open a pasted report link, Try | none | none |
| `/join` | Participant entry and pasted-link validation | invite, from fragment or paste | `/` |
| `/consent` | Plain practice-call consent, optional stats opt-in, one large start | invite in memory | `/` |
| `/try` | Creates a tryout invite, then goes to consent | none | `/` |
| `/drill` | The chat drill with the DRILL badge and End drill | session | `/` |
| `/debrief` | Quick then full debrief, share, delete | session | `/` |
| `/report` | Read-only shared debrief for a family member | report | `/` |
| `/about` | What this is, what it is not, storage, deletion, how it works | none | `/` |

Consent is also reachable at `/consent`, which is the same screen `/try`
navigates to after it creates the tryout invite.

## Token shapes

| Token | Prefix | Example | Source |
| :--- | :--- | :--- | :--- |
| Invite | `inv_` | `inv_0123456789abcdef` | `POST /v1/invites` |
| Session | `ses_` / `tok_` | `ses_...` | `POST /v1/sessions` |
| Report | `rep_` | `rep_0123456789abcdef` | `POST /v1/sessions/{id}/share` |

The invite link is `https://host/#token=<invite>`. The report link is
`https://host/#report=<report>`. The fragment is chosen so a token is never sent
to the web host in a request line, never logged by a proxy, and never lands in a
`Referer` header (the host also sends `Referrer-Policy: no-referrer`).

## Bootstrap: reading and removing a fragment token

`main()` runs before the first frame:

1. `configureUrlStrategy()` installs the path URL strategy on web.
2. `takeInitialLink()` reads the fragment.
   - On web, `initial_link_web.dart` parses `token` / `invite` / `report`, then
     calls `history.replaceState(null, '', <url without fragment>)`. The token
     is gone from the address bar and from copied links immediately.
   - On Android, `initial_link_io.dart` returns `InitialLink.none`; there is no
     URL fragment to read.
3. The result is injected as an immutable `initialTokensProvider` override, so
   the token store starts with the token already in memory.
4. The router picks its first location from the token: `/report` when a report
   token exists, `/join` when an invite token exists, otherwise `/`.

Nothing is written to `localStorage`, `sessionStorage`, cookies, or a database.
A page refresh loses every token, on purpose.

## Guards

Every screen that needs a token reads it from the in-memory `TokenStore` and
renders a calm recovery state instead of crashing or showing a session id.

| Screen | Missing token behaviour |
| :--- | :--- |
| `/join` | Explains that the link did not carry an invite, offers paste and Try |
| `/consent` | Sends the person back to `/join` |
| `/drill` | "Open your link again" state with Try and Join actions, never a spinner |
| `/debrief` | Shows the shared-session-gone state, offers Try |
| `/report` | Shows the report-gone state for an invalid, expired, or deleted report |

The "open your link again" state is what a person sees after refreshing the page
mid drill. It is deliberate: a refresh is a new browser session and there is no
safe way to keep a session token across a reload without writing it to storage.

## Creating links

- `LinkBuilder` in `app/lib/core/link_builder.dart` builds every outbound link.
  The base is the current web origin on web and `PUBLIC_WEB_URL` on Android.
- `LinkBuilder.inviteTokenFrom` and `reportTokenFrom` accept a bare token, a
  full link with the token in the fragment, a full link with the token in a
  query, or a trailing path segment. This is what makes pasted links from other
  apps work.
- Shared text is plain text with no emoji, formatted by ARB strings.

## Environment

| Variable | Default | Use |
| :--- | :--- | :--- |
| `API_BASE_URL` | `http://127.0.0.1:8000` | Backend origin for every API call |
| `PUBLIC_WEB_URL` | `http://127.0.0.1:8080/` | Base for invite and report links built on Android |

On web the app builds links from `Uri.base`, so a link shared from a deployed
origin points at that same origin.

## Error handling

- An unknown path renders the home screen through the router's `errorBuilder`,
  so a stray URL is never a blank page.
- A 401 or invalid token on a guarded screen becomes the matching recovery
  state. The app never shows a raw session id or a stack trace.
