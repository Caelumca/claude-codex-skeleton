---
name: session-memory
description: Persistent memory and session-handoff protocol for Fable sessions. Maintains a decision log (why choices were made), a working notes file (current state of play), and a defined boot/handoff sequence so a fresh context window resumes work without re-deriving past reasoning. Use at the start of any session on an existing project, whenever an architectural or contract decision is made or reversed, whenever a review-loop or qa-loop ruling constrains future work, when context is running long and compaction is near, and at the end of any working session. Also use when the user asks to "pick up where we left off", resume, or continue a project.
---

# Session memory: decisions, notes, handoff

Context windows end; projects don't. This skill defines the three files that
carry state across resets and the exact protocol for writing and reading them.
The principle is the article's structured note-taking: persist outside the
window, pull back in on demand — and keep what's persisted *distilled*, because
these files are read at every boot and compete for the same attention budget as
everything else.

## The two memory files

**One fact, exactly one home.** The system has several memory surfaces, and the
same fact written to two of them will eventually disagree. The routing rule:
**CLAUDE.md** (if the project has one) holds what doesn't change — stack,
commands, house rules; **`decisions.md`** holds *why*; **`working.md`** holds
*now*; **skills** hold *how to work*; **`.briefs/`** holds what each lane was
told. Before writing anywhere, ask which of these the fact is — and if it
already lives elsewhere, link, don't copy.

### `.notes/decisions.md` — why things are the way they are

Append-only log of rulings that constrain future work. A decision earns an
entry when reversing it later would be expensive or when a future lane could
plausibly contradict it. That means:

- Architecture choices and the alternatives rejected, one line each on *why
  not* — the rejected options are the valuable half; they stop the same debate
  from re-running in a fresh context.
- Contracts frozen: schemas, signatures, invariants that briefs will cite.
- Rulings on review-loop design-events and qa-loop escalations.
- Reversals — a decision that was overturned stays in the log with a pointer to
  the entry that supersedes it. Deleting it invites the original mistake back.

Entry format, deliberately rigid so entries stay grep-able and short:

```
## D-014 · 2026-08-10 · Job queue: postgres SKIP LOCKED, not Redis
Status: active            (active | superseded-by D-0xx)
Why: single store, transactional with domain writes, load fits.
Rejected: Redis (second failure domain), in-proc (loses jobs on deploy).
Binds: any lane touching src/jobs/** cites this in its brief's contracts.
```

Five lines is the target. If an entry wants a page, the page belongs in a design
doc and the entry links to it. **Not** logged: routine implementation choices a
brief already covers, anything a lane can re-derive cheaply from the code.

### `.notes/working.md` — the state of play

Overwritten freely, never archival. One screen, maximum. Holds only what a
fresh Fable needs to resume *this* piece of work:

- Current objective, one paragraph.
- In-flight lanes and their brief files under `.briefs/`, if any survived the
  session end.
- Next 1–5 concrete steps, in order.
- Open questions blocked on the operator.
- Landmines — the non-obvious thing that will bite next session ("the staging
  DB is one migration behind; run 0042 before trusting test failures").

If `working.md` exceeds a screen, it has absorbed decisions (move them to
`decisions.md`) or history (delete it — git remembers).

## Boot sequence for a fresh session

On any session over an existing project, read in this order and *only* this
order, stopping as soon as there's enough to act:

1. `.notes/working.md` — the resume point. Usually sufficient.
2. `.notes/decisions.md` — skim headers; read bodies only for entries the
   current task binds against.
3. `.qa/issues.md` and `.review/findings.md` — open items only.
4. Code — just-in-time, per task, never as a boot-time sweep.

What is *not* done at boot: reading raw logs, re-reading resolved findings,
re-verifying past decisions "to be safe". Re-derivation is the failure this
skill exists to prevent; trust the log, and if the log proves wrong, fix the
log-writing habit, not the boot sequence.

## Write triggers during a session

Memory written only at session end is memory that dies with a crashed context.
Write at the moment of the event:

- **Decision made or reversed** → `decisions.md`, immediately, before the next
  lane is briefed against it.
- **Review-loop verdict or qa-loop escalation ruling** that binds future work →
  `decisions.md`.
- **Objective or plan changes shape** → `working.md` rewritten.
- **Landmine discovered** → `working.md`, immediately — landmines are precisely
  the context that dies in compaction.

## Handoff: ending a session deliberately

Before ending (or when compaction approaches), one explicit pass:

1. Rewrite `working.md` from scratch for a reader with *zero* shared context.
   The test: could a fresh Fable, given only the three files and the repo,
   resume within one turn? Falsely assumed shared context is the classic
   handoff failure.
2. Sweep the session for unlogged decisions — especially rulings given verbally
   to lanes mid-flight, which otherwise exist nowhere.
3. Leave `.qa/` and `.review/` honest: no finding marked resolved that isn't.

If context dies *without* a handoff pass, next session's first job is
reconstruction: rebuild `working.md` from git log, open findings and issue
status — as a scout-lane task feeding Fable, not a Fable solo grind.

## Compaction interplay

When compaction looms, prefer the handoff pass over trusting summarization:
write the files, then compact. A summary is lossy in ways that only surface
later; the files are lossy in ways *chosen deliberately*. Anything critical
should live in the files before it lives only in a compaction summary.

## Files

```
.notes/
├── decisions.md   # append-only, entries superseded not deleted
└── working.md     # overwritten freely, one screen max
```

Fable owns both files. Lanes may *read* them (briefs can point at specific
decision ids) but never write them — a lane that wants a decision recorded
reports it, per fable-orchestration, and Fable logs the ruling.
