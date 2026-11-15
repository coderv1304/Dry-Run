# Demo day runbook

The drill is a live conversation with a backend. Demos fail in predictable ways,
so this page is a decision tree, not a wish list.

## Ten minutes before

1. **Warm the backend.** Open `/healthz` twice, then `/readyz` once. `readyz`
   performs `SELECT 1`, so a green `readyz` means the database is reachable.
2. **Keep it warm.** Leave one browser tab open on the landing page and one on
   the app home. If the host sleeps idle services, a five minute ping keeps the
   instance up.
3. **Warm the web app.** Load the app once on the demo laptop and once on the
   demo phone so the engine files and fonts are cached.
4. **Check the flags.** `LLM_ENABLED` decides whether officer lines are model
   written or scripted. Both are fine; know which one you are showing. If the
   budget is nearly spent, or the network is unpredictable, set
   `LLM_ENABLED=false` and present the scripted tier as the deterministic mode.
5. **Sign nothing in.** There is no account and nothing to log into, so there is
   nothing to reset in a hurry.
6. **Have the backup video open in a local player**, paused on the first frame.
   Not in a tab that needs the network.

## During the demo

Say the frame first: "This is a practice drill. The officer is fictional. I can
stop at any time." Then run `/try` and take the drill as yourself.

## When something breaks

| What you see | What to do | What to say |
| :--- | :--- | :--- |
| Turn spins for more than three seconds | Wait one beat. The client retries with the same `turn_id`; a retry is safe by design. | "The reply is slow; the drill retries the same turn, so nothing is lost." |
| Provider error, or officer line never arrives | Nothing. The service falls back to reviewed scripted lines and the drill continues. | "That was the scripted fallback, which is what runs when the model is unavailable." |
| `503` from every screen | The database is unreachable. Stop tapping. | "The database is down, so I will show the recorded walkthrough." |
| Budget exhausted (warning in logs, scripted lines) | Continue. It is designed behaviour. | "The daily model budget is spent, so the drill switched to scripted lines." |
| Voice button does nothing, or speech is wrong | Switch to typing immediately; do not debug on stage. | "Voice needs the phone's speech service; typing always works." |
| Web app shows the "open your link again" state | Reload once, then go back to `/`. A refresh is a new session by design. | "A refresh drops the token on purpose, so I will start a fresh drill." |
| No network at all | Stop the live drill. | "The drill needs the backend, so here is the recorded walkthrough." |

## Switch to the scripted tier on purpose

If the venue network is bad, do not gamble. Before the demo:

```sh
LLM_ENABLED=false   # backend environment, then restart the service
```

Scripted lines are reviewed, deterministic and fast, and the officer still
reacts through engine state. Say that out loud; it is a feature of the design,
not a confession.

## Switch to the recorded walkthrough

The demo build needs no backend and no microphone:

```sh
make demo-web    # builds and serves the recorded walkthrough on :8080
```

It opens on a fixed transcript with the DEMO banner and a canned debrief. Use
it when the network, the database or the phone's speech service fails twice.

## If the live drill fails entirely

1. Play the backup video from the start.
2. Narrate the two moments the video cannot show: the engine deciding the next
   officer line, and the debrief quoting the participant's own words.
3. Offer the local demo build afterwards so the judge can tap it themselves.

## Backup video checklist

- [ ] Recorded at 1080p or better, phone plus laptop screen.
- [ ] Shows consent, the DRILL badge, at least four officer lines, the debrief
      with a quote, and the one habit.
- [ ] Audio is audible on laptop speakers without a headset.
- [ ] Under three minutes, so it fits inside the pitch.
- [ ] Stored locally and on one cloud account, both tested in airplane mode.
- [ ] Starts with the frame sentence, so a silent autoplay still makes sense.

## After the demo

- Delete the demo session from the debrief screen, on stage if there is time.
- If a volunteer ran a drill, export the aggregate the same day, before
  retention purges it (`docs/VOLUNTEER_PROTOCOL.md`).
- Note anything that broke in `docs/BUILD_LOG.md` so the next run is calmer.
