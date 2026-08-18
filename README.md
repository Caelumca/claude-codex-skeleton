# Project Skeleton

A minimal starting scaffold for working on a codebase with an AI coding agent.

It is not a framework and it has no dependencies — just a small set of empty
files that give an agent a fixed place to put things: what the project *is*,
*why* past choices were made, what is happening *right now*, and *how* to work.
Drop it into a new repo, fill in `CLAUDE.md`, and start.

## Why

Context windows end; projects don't. Without somewhere to persist state, every
new session re-derives the same reasoning, re-litigates settled decisions, and
re-discovers the same landmines. This skeleton is the smallest structure that
prevents that:

**One fact, exactly one home.**

| File | Holds |
|---|---|
| `CLAUDE.md` | What doesn't change — stack, commands, house rules |
| `.notes/decisions.md` | *Why* — append-only log of rulings that bind future work |
| `.notes/working.md` | *Now* — current objective, next steps, landmines |
| `.claude/skills/` | *How to work* — reusable protocols |
| `.briefs/` | What each delegated lane was told |
| `.qa/issues.md` | Open test / lint / security issues, triaged |
| `.review/findings.md` | Review findings on delegated work |

## Layout

```
.
├── CLAUDE.md              # project router — fill the ALL-CAPS slots on day one
├── init.sh                # copy this skeleton into a project
├── LICENSE                # MIT
├── .claude/skills/        # working protocols
│   ├── session-memory/
│   └── qa-loop/
├── .briefs/               # one file per delegated lane
├── .notes/
│   ├── decisions.md       # append-only
│   └── working.md         # overwritten freely, one screen max
├── .qa/issues.md          # triaged issues (raw runner logs are gitignored)
└── .review/findings.md
```

All the state files ship empty. They are templates showing the expected shape,
nothing more.

## Quick start

```bash
git clone https://github.com/YOUR-USERNAME/project-skeleton.git
bash project-skeleton/init.sh /path/to/your-project
```

`init.sh` copies the directories in without overwriting anything that already
exists, and appends `.qa/raw/` to the project's `.gitignore`.

Then:

1. Fill in the **Project** section of `CLAUDE.md` — one sentence on what this
   is, the stack, and the run / test / lint commands.
2. Pick a **mode** (see below) and delete the other one.
3. Write your house rules and your "do not touch" list.

## Two modes

`CLAUDE.md` asks you to pick one. Switching later is fine.

**VIBE** — prototypes, experiments, solo scripts, anything disposable.
Work inline. No lanes, no briefs, no review pass. Only two habits survive: run
the tests before claiming done, and log a decision entry for anything you'd
hate to re-debate.

**FULL** — anything with users, collaborators, or a future.
All protocols active: session memory carries state across sessions, the QA loop
keeps the codebase green and safe, review gates every delegated diff, and
briefs always live as files in `.briefs/`.

A VIBE project that gains a second contributor, a deploy target, or a paying
user becomes FULL. Demotion never happens silently — it's a logged decision.

## Skills included

Two to start with:

- **`session-memory`** — the decision log, the working notes, and the exact
  boot / handoff sequence so a fresh context window resumes work in one turn
  instead of re-reading the whole repo.
- **`qa-loop`** — detect → triage → fix. Deterministic runners execute tests,
  lint, typecheck and security scanners; a cheap triage lane distills raw
  output into a stable issue log; fixer lanes touch implementation only, never
  tests. That last rule is the one that keeps the loop from lying to you.

`qa-loop` references two skills that aren't in this repo yet — an orchestration
skill governing how lanes are spawned, and a review skill gating delegated
diffs. `.briefs/` and `.review/` are here as placeholders for them. Neither is
needed for the loop itself to be useful.

Skills are plain markdown with YAML frontmatter, so adding your own is just
creating `.claude/skills/<name>/SKILL.md`.

## License and credit

This is my personal project skeleton. Feel free to use and modify, but please
give credit.

Released under the [MIT License](LICENSE) — which means keeping the copyright
notice in copies and substantial portions is the credit I'm asking for.
<!-- test commit -->
