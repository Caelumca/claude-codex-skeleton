---
name: qa-loop
description: Detect-triage-fix loop for keeping a codebase green and safe. Deterministic runners execute tests, lint, typecheck and security scanners (secret scanning, dependency audit, static analysis); an Opus triage lane distills raw output into a stable issue log; fixer lanes run only on issues Fable has approved and briefed. Use whenever setting up or running a test/lint watch loop, triaging build, test or security-scan failures, logging recurring errors, or deciding whether a failure should be auto-fixed. Pairs with the fable-orchestration skill, which governs how the lanes themselves are spawned.
---

# QA loop: detect, triage, fix

A working loop for keeping a codebase green without letting the loop quietly lie to
you. Delegation mechanics (model choice, lane caps, brief format, supervision) come
from the **fable-orchestration** skill — this file only covers the loop itself.

## Two rules that make or break this

**1. Running is not agent work.** Executing tests, lint and typecheck requires no
judgment. A watcher, git hook, or CI job runs them; agents are spawned only *on
failure*, and only for triage or repair. Nothing is "continuously running" except the
runner itself. An agent idling in a loop is pure cost.

**2. A fixer that can edit tests will make failures disappear instead of fixing
them.** Told to turn the suite green, the cheapest path is not repairing the code —
it is loosening an assertion, skipping the test, widening a tolerance, wrapping the
call in try/catch. The log then reads "fixed", CI is green, and the bug is still
there. This failure mode is silent and it destroys the signal you built the loop for.

Therefore: **fixer lanes may edit implementation only.** Tests, assertions, fixtures,
contracts and CI config are off-limits — put them in the brief's *do not touch*
section every time. A fixer that believes the test itself is wrong does not change
it; it reports that as a finding and escalates to Fable. That judgment call is never
delegated.

## The three roles

| Role | What runs it | Cost |
|---|---|---|
| **Runner** | Script / watcher / hook / CI | No model |
| **Triage** | Opus lane | Cheap, distills |
| **Fixer** | Opus lane (per fable-orchestration) | Gated by Fable |

### Runner

Deterministic. Runs the suite, writes raw output to `.qa/raw/<timestamp>.log`,
exits. No summarizing, no interpretation, no model. Raw logs are disposable.

Security scanning is runner work, not agent work — the "running is not agent
work" rule applies with full force here. Secret scanning (gitleaks), dependency
audit (`npm audit` / `pip-audit` / `cargo audit`), and static analysis (semgrep
with a curated ruleset) all run as deterministic runners on the same cadence as
tests, writing to the same `raw/` directory. Do not spawn an agent to "look for
vulnerabilities" — an agent free-hunting for security issues produces plausible
noise; scanners produce triageable signal. The one security task that *is* model
work — design-level threat analysis when a new endpoint, auth flow, or data
boundary is introduced — is not this loop's job at all: it is Fable's
architecture work, done at design time.

### Triage lane

An Opus scout lane reads the raw log and updates `.qa/issues.md`. **Raw output never
enters Fable's context** — this distillation is the whole point of the lane.

Each issue record carries:

- **id** — a stable hash of the failure signature (test name + error type + top
  meaningful frame). Stability is critical: if the id drifts, the same failure opens
  a new record every run and the log becomes noise within days.
- **first seen / last seen / count** — see escalation below.
- **class** — broken test, flake, type error, regression, dependency, security,
  unknown. Security findings additionally carry the scanner's own severity and
  rule id in the evidence field; triage never downgrades a scanner severity —
  disputing a finding is Fable's call, recorded as `wontfix` with a reason.
- **evidence** — the shortest excerpt that identifies the failure, plus the path to
  the raw log. Not the log itself.
- **status** — open, briefed, fixed, escalated, wontfix.

Triage never fixes anything and never edits code. If it can't classify a failure,
`unknown` is a valid answer and better than a guess.

### Fixer lane

Spawned only for issues Fable has read and turned into a brief. Never spawned
straight from the log. Output goes to `.qa/fixes.md`: which issue, what changed, why,
and which test now proves it. A fix with no verification is not a fix.

**Prefer fresh eyes over familiarity.** The lane that wrote the code under a
spec carries that spec's misreadings into the repair. Spawn the fixer as a
fresh lane whose input is the issue record and Fable's brief — not the original
implementation lane resumed. Model choice follows fable-orchestration; if the
operator has sanctioned an additional model for a scoped task, a cross-model
repair is worth taking, but that exception is orchestration's to grant, not
this loop's.

## Escalation on repeat

`count` is a free diagnostic. **The same id fixed twice and returning a third time is
not a code problem** — it is an ambiguous brief, a wrong contract, or a design flaw.
Stop spawning fixers, mark it `escalated`, and hand it to Fable. This is the
automatic trigger for fable-orchestration's "re-brief, don't patch" rule.

Flakes deserve their own handling: an intermittent failure repaired as if it were
deterministic usually gets "fixed" by suppression. Mark it `flake`, log the rate, and
leave it for Fable.

## Rollout: detection first

**Do not build the closed loop on day one.** Start with runner + triage only, every
fix gated behind Fable. After a few weeks the log itself tells you which classes are
safe to automate:

- **Usually safe** — type errors, missing imports, formatting, mechanical API renames.
  Narrow, verifiable, hard to fake green.
- **Never automatic** — behaviour regressions, flakes, anything touching a contract or
  a public interface. These are architecture events wearing a test failure's clothes.
- **Permanently never automatic: the `security` class.** It does not graduate, no
  matter how clean the log looks. A leaked secret needs rotation, not just
  deletion from the diff; a vulnerable dependency bump can be a breaking change;
  a semgrep hit can flag a design flaw. Every security fix is briefed by Fable,
  and a true-positive secret leak is escalated to the operator — rotation
  happens outside the codebase and outside this loop.

Promote a class to auto-fix only once the log shows fixes in that class were correct
without Fable's intervention. Building the loop the other way round leaves you with
no way to measure whether any fix was ever right.

## Files

```
.qa/
├── raw/        # runner output, disposable
├── issues.md   # triage writes, stable ids
└── fixes.md    # fixer writes, one entry per repair
```

Fable reads `issues.md` and `fixes.md`. Fable does not read `raw/` unless an issue
specifically demands it.
