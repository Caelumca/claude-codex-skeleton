# CLAUDE.md — project router

> Template. Fill the ALL-CAPS slots on day one; delete lines that don't apply.
> This file holds what doesn't change. Why → `.notes/decisions.md`.
> Now → `.notes/working.md`. How to work → `.claude/skills/`. One fact, one home.

## Project

- **What this is:** ONE SENTENCE.
- **Stack:** LANGUAGES / FRAMEWORKS / DB.
- **Run:** `COMMAND`
- **Test:** `COMMAND`
- **Lint / typecheck:** `COMMAND`
- **Entry points:** `src/MAIN`, `src/...`

## Mode: [ VIBE | FULL ]  ← pick one, switching later is fine

**VIBE** — prototypes, experiments, solo scripts, anything disposable.
- Work inline. No lanes, no briefs, no review pass.
- Only two habits survive: run the tests before claiming done, and drop a
  D-entry in `.notes/decisions.md` for anything you'd hate to re-debate.
- `working.md` gets one line at session end: where you stopped.
- Skills active: **session-memory** (minimal), everything else dormant.

**FULL** — anything with users, collaborators, or a future.
- All four skills active: fable-orchestration governs delegation, qa-loop
  keeps it green and safe, review-loop gates every delegated diff,
  session-memory carries state across sessions.
- Boot sequence per session-memory: working.md → decisions.md headers →
  open issues/findings → code just-in-time.
- Briefs are files in `.briefs/`, always.

Promotion rule: a VIBE project that gains a second contributor, a deploy
target, or a paying user becomes FULL. Demotion never happens silently —
it's a D-entry.

## House rules

- STYLE / FORMATTING CONVENTIONS (one line each, only the non-obvious ones)
- THINGS THAT ALWAYS APPLY ("never commit .env", "migrations via CLI only")

## Do not touch

- PATHS OR SYSTEMS THAT ARE OFF-LIMITS WITHOUT ASKING
