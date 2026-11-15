# Volunteer protocol

For a small, informal session: a handful of colleagues or family members run one
drill each so we can see whether the drill holds up and whether anything breaks.
This is not a study. No result from it may be reported as evidence of
effectiveness, and no number from it goes into any copy.

## Consent, read aloud before the session

> "This is a practice call. It is a fictional officer of a fictional agency, and
> nothing you type is real. You can stop at any time by tapping End drill, and
> you can delete the whole session from the debrief screen. The only thing we
> keep is the transcript and the debrief, and it is deleted after seven days.
> If you say yes to the optional question, we also count your session in a
> small anonymous tally so we can see how many people finished. That tally has
> no name, no email and no phone number, and it is counts only. You can say no
> and still do the drill."

Consent points, each recorded separately by the product itself:

| Consent | Required | Where it is asked |
| :--- | :--- | :--- |
| Practice call consent | yes | `/consent`, before the first turn |
| `stats_opt_in` anonymous counts | no | the same screen, its own control |
| Share consent | no | only when the person taps share |
| Voice opt in | no | only when the person taps Use voice |

## What is recorded

- The participant's text for each turn, after redaction of OTP, card number,
  PIN and account patterns.
- The label, confidence and quote offsets the rules produced, the stage and
  pressure after each turn, and the officer line that was shown.
- The debrief ids: which moments did well, which to watch, and the one habit.
- Nothing else. No audio, no device identifiers, no IP address in the database,
  no email, no name.

## Anonymising

- Sessions are identified by a random id. Tokens are random and hashed at rest.
- The invite cohort is the only grouping value, for example `tryout` or
  `volunteers-november`, and it identifies no person.
- The export refuses to run at all on fewer than three sessions in a cohort, so
  a single person's transcript cannot be isolated from the aggregate.
- Quotes stay inside the session and the debrief; the export never prints
  participant text.

## No real money, no real data

- Say plainly: never type a real OTP, card number, PIN, account number or Aadhaar
  number into the drill, even though it is practice. The drill warns when a
  message looks like one.
- No payment, no donation and no bank detail is collected anywhere in the
  product.
- If someone volunteers a real document to test the redaction, do not accept it.

## The session itself

1. Ask the person to open the link on their own phone.
2. Read the consent paragraph above, then let them tick their own consents.
3. Let them finish or stop; do not coach during the call.
4. After the debrief, ask one question only: "Was there a moment that felt
   familiar?" Write the answer as a note, without their name.
5. Export the aggregate after the session, before retention deletes it.

## Exporting the aggregate

```sh
python scripts/export_volunteer_stats.py --cohort volunteers-november
```

The script prints a table of counts and one caption:

> informal, small sample, not representative

Rules the script enforces:

- only sessions with `stats_opt_in` true,
- only the named cohort,
- refuses below three sessions,
- counts only: sessions started, sessions finished by each end reason, and the
  habit that was given. No text, no ids, no timestamps finer than the day.

## Runbook note: export before retention

Default retention is seven days (`RETENTION_DAYS`). The purge loop deletes
sessions, transcripts and reports after that, so export the aggregate on the day
of the session or the next morning at the latest. A missed export cannot be
recovered, by design. If a cohort would be lost, the honest move is to say the
data is gone rather than reconstruct it from memory.

## What may be said afterwards

- "Seven people ran one drill each. Six finished. Two said the isolation line
  felt familiar." That is a session note, not a finding.
- Never: "people improved", "the drill works", "most participants spotted it".
  Three to thirty volunteers can show a bug, not an effect size.
