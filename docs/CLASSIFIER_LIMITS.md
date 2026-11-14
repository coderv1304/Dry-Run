# Classifier Limits

The live classifier is deterministic and rule-based. It normalises input with
NFKC, lowercases it, and matches English, common Roman transliterations, and
Devanagari keywords. It returns one of P1-P4, C1-C4, or neutral with a
confidence and a verbatim quote.

## What it does well

- Catches explicit refusals, verification requests, family mentions, scam
  awareness, identity disclosure, isolation acceptance, urgency compliance,
  and transfer compliance.
- Handles simple negation near compliance phrases, for example "I will not
  send money" becomes P1 rather than C4.
- Returns neutral when two labels tie or nothing matches, instead of guessing.

## Known limits

- Sarcasm, irony, and indirect speech are not understood.
- Code-mixing beyond the listed transliterations can be missed.
- Short answers such as "haan" or "ok" are treated as neutral because they are
  ambiguous without context.
- Homonyms (for example "account" in a banking or non-banking sense) can tie
  and become neutral.
- Spelling variants and novel slang are not learned automatically.
- The classifier does not identify whether a claim is true. It only labels the
  shape of the participant's response.
- Fixture results are for internal development only. They are not an accuracy
  claim, are not validated, and must never appear in user-facing copy.

The internal script `scripts/eval_classifier.py` prints a confusion table. It
is a debugging aid, not a product metric.
