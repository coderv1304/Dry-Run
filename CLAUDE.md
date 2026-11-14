# Standing Rules for Dry Run

Every prompt MUST read this file, docs/ARCHITECTURE.md, and the relevant contract before writing code.

## Rules

1. **Plan first.** Write `docs/PLAN_<id>.md` (30 lines max) before coding. Read CLAUDE.md, docs/ARCHITECTURE.md, and the relevant contract section before working.
2. **Small conventional commits.** Run `make test` after every milestone.
3. **No dead code on shipped paths.** No TODOs, stubs, `pass` bodies, fake data, or commented-out code on shipped paths. Unfinished optional work is removed or put behind a flag and listed in `docs/SCOPE_AND_GATES.md`.
4. **Never weaken gates.** NEVER weaken, skip, or delete a test, lint, gate script, or BANNED_UI rule to get green. If a rule seems wrong, log it in `docs/DECISIONS.md` and keep the rule.
5. **Contract discipline.** Contract changes only via a `contracts/CHANGELOG.md` entry, regenerated fixtures, and backend plus client updated in the same commit.
6. **No network in tests.** Tests never touch the public network; providers are mocked.
7. **No secrets.** No secrets in the repo; only `.env.example`.
8. **Single-source strings.** Every user-visible string lives in its single-copy source: app copy in ARB files, landing copy in `landing/content.json`, officer lines in scenario YAML.
9. **Human-only work.** Human-only work goes into `docs/HUMAN_TODO.md`; continue with what you can do.
10. **No questions.** Do not ask the user questions. Stop only for a missing gate or a missing tool that blocks all progress. Decide, record in `docs/DECISIONS.md`, continue.
11. **Final report.** Final report (40 lines max): built, decisions, deviations, skipped, risks, commands to run.

## Key Principle

**THE LLM ONLY WRITES OFFICER LINES. THE ENGINE DECIDES.**

The engine is a pure deterministic function. Turn classification uses deterministic rules. The LLM's only job is generating the fictional officer's dialogue. Debrief labels come from rules (quick) or structured LLM output (full), never free text.

## Gate System

Before starting work for Prompt N, run `scripts/check_gate.sh <N-1>` to verify the prerequisite gate passed. Valid gate ids: 0, 1, 2, 3, 3b, 4, 4b, 5.

## Project Context

"Dry Run" is a drill for digital arrest scam calls. It is practice, not protection. Never claim it measures real-world vulnerability, prevents fraud, or is validated.

## Banned UI

See `docs/design/BANNED_UI.md`. Those 18 rules are BINDING and override both design skill files.
