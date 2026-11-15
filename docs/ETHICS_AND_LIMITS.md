# Ethics, dual use, and the five hardest questions

Dry Run is a practice drill for a crime that ruins families. Practising a
scripted version of that call carries real risks: it can frighten someone, it
can teach a scammer, and it can be oversold. This page answers the five
questions a judge is most likely to ask, plainly, and states where the line is.

**This is not legal advice.** Nothing in the app, the landing page or these
documents is legal, financial, medical or security advice, and nothing here is
a substitute for guidance from a bank, a police service, a telecom or a
government helpline.

## 1. Is this a manual for scammers?

Partly, and we accept that. Anything that shows a scam script can be read as a
training aid, so the choices below reduce the value to a bad actor instead of
pretending the risk is zero.

- The scenario is one published pattern that is already described in news
  reports and awareness campaigns: an officer, a parcel, isolation, urgency,
  a transfer. There is no novel or effective playbook in it.
- The officer's lines are fiction and deliberately weak as persuasion: no
  personal data, no real case numbers, no scripted answers to a sceptical
  target.
- The product ends with the counter move, not the scam: the drill's last habit
  is to hang up and call the number on the card.
- No endpoint serves the scenario files. The engine and scenario live on the
  server; the app cannot download a script to run offline.
- The production build contains no demo transcript, which
  `tool/check_demo_strings.py` proves on the compiled binary.

## 2. What happens to private data?

- No account, no email, no phone number. A drill needs only the link.
- Tokens travel in headers or the URL fragment, never in a path or query
  string, and are hashed at rest.
- Participant text is redacted before storage for OTP, card, PIN and account
  shaped strings, and the drill warns the person when it fires.
- Sessions, reports and invites expire in seven days by default and a purge
  loop deletes them; deletion from the debrief screen invalidates the report
  link immediately.
- No analytics, no third party scripts, no fonts from a CDN, on any surface.

## 3. Is this safe for an older person who is frightened of these calls?

- The DRILL frame is visible for the whole call: a badge in the drill header
  and a plain notice before it starts.
- The officer is always a fictional agency, never a real one, and the first
  line can say it is a practice call.
- There is a consent screen before any turn, and `End drill` is available on
  every screen of the call.
- The debrief never scores the person. Every sentence comes from a reviewed
  template, and the copy test refuses words like gullible or victim in any ARB
  or scenario file.
- If a person types something that looks like real credentials, the drill stops
  escalating, warns them, and the line writer switches to a scripted safe line
  rather than improvising.

## 4. Does it actually work?

Unknown, and the product says so. There is no study, no control group and no
follow up. The classifier is deterministic rules with a published list of
limits, and every score shows its quote and confidence so a person can disagree. As far as we could find, no evaluated version exists to copy a number from.
with it. No percentage about how often the drill changes behaviour appears in
any copy, and `scripts/claims_lint.py` fails the build if one appears. As far
as we could find, nothing like an evaluated version of this exists to copy a
number from.

What we can say with evidence:

- The engine is a pure function and replay never calls a model, so the drill a
  judge sees is the drill that was tested.
- Latency, fallback behaviour and retention are measured and recorded in
  `docs/PERF.md` and `docs/WEAKNESS_REPORT.md`.
- The copy is linted for promises, and the repo refuses to ship a statistic
  that no human has verified.

## 5. Why not just warn people?

Warnings assume a calm reader. A digital arrest call is engineered to remove
calm: someone is told a parcel of drugs was found in their name, that they
cannot tell their family, and that a transfer clears it. Reading a warning is
not the same as having answered that sentence out loud. A ninety second
rehearsal is cheap, repeatable, and can be handed to the person who needs it.
A campaign can explain the pattern; only practice lets someone hear themselves
comply and notice it.

## Lines we do not cross

- No real agency names, badges, real case numbers or real officer identities.
- No claim that the drill has any measured effect, or that it measures risk.
- No figure, no leaderboard, no score out of ten, no certificate.
- No collection of real credentials, and no prompt that asks for one.
- No screen that shows a person's words to anyone without their explicit share
  consent, and no way to keep a report alive after deletion.
- No training material that a stranger could reuse to run the scam: the
  scenario is not exposed as an endpoint or an app asset.
