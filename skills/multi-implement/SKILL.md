---
name: multi-implement
description: "Implement a set of tickets in parallel, one builder + one reviewer subagent each, then land them. Tracker-agnostic (beads, GitHub issues, local markdown)."
argument-hint: "<epic | ticket ids | tickets folder | run slug to resume> [budget floor] [model]"
disable-model-invocation: true
---

Take a spec or a set of tickets to done. You own the **bar**, the **slice**,
the **run state** and the **landing**; subagents own the building and the
review. You orchestrate only: you never edit product code yourself.

One ticket, or a spec that is really one ticket: run `/implement`, stop here.
An argument naming an existing `.local/runs/<slug>/run.md`: go to **Resume**.

## 0. Preflight (one screen, no edits)

Read `docs/agents/workflow.md` (missing → run `repo-setup` first) and the
newest `.local/handoffs/` file. Then:

1. Resolve every ticket in the repo's tracker with its blockers, labels and
   comments. Flag tickets claimed by another session or already landed.
2. Base: current branch, clean tree, up to date with its upstream. Use the
   path `git rev-parse --show-toplevel` prints for every worktree (Windows
   casing breaks worktrees otherwise).
3. Run the **Preflight** commands from `workflow.md` (hosts, accounts,
   containers). A failure goes on the needs-you list, not into a builder.
4. Tickets not yet checked for readiness: run `spec-check` on them. Skip only
   when the user says so or the spec was checked after its last edit.
5. Collect **every** question the run will need into one numbered list with a
   recommended answer each: open HITL decisions, tokens or rights to provide,
   landing choices, ambiguous tickets. Ask them now, together.

Output: the needs-you list, the questions, and an **AFK verdict** — `ready for
an unattended run`, or what still blocks it (including commands likely to
need an interactive approval, so the user can allow them before leaving).

## 1. Set the bar

Pin one **bar** per ticket — the standard its result is compared against.
Named, fetchable, comparable:

- An exemplar already in this repo — the module, test file, FB or endpoint
  the new work should read like. Name the path.
- The ticket's acceptance criteria, rewritten as pass/fail checks, each with
  the command or observation that proves it.
- The test seams, each with one line on what it catches and what it misses.

A bar **restates** the ticket; it adds no requirement the ticket lacks. If one
seems missing, it is a question for step 0, not a line in the bar.

Adjectives ("clean", "production quality") leave the review arguing with
itself; name a thing instead. Every claim a comment or doc makes must be
measured this session or cited to a file:line.

## 2. Slice into waves

Fan out **decoupled** tickets in parallel. Run **coupled** tickets — same
files, or blocking each other in the tracker — in sequence. The tracker's
ready/blocked graph is the slice: what is ready is a wave.

Give each parallel builder its own git worktree on its own branch from the
run base. A shared tree means shared build state, and concurrent builds
invent errors that cost a builder a round to chase.

Show one table — ticket, wave, owned files, bar — plus the critical chain and
the widest wave. Take corrections; dispatch on the user's go.

## 3. Run state

Write `.local/runs/<slug>/run.md` (`.local/` in `.git/info/exclude`) before the
first dispatch and update it at every transition:

```
goal: <the spec's headline goal, one line>
base: <branch> @ <sha>   landing: <policy from workflow.md>   floor: <usage floor or none>
| ticket | wave | state | worktree/branch | builder id | review | landed sha | follow-up |
needs-you: <open items>
```

States: queued, building, reviewing, fixing, landed, landed-with-issue,
blocked, dropped. Every status answer comes from this file. It is what
survives `/compact` and `/clear`.

## 4. Build

Each ticket is worked by a **pair**: a `ticket-builder` and a
`ticket-reviewer`. One exchange between them, then it lands.

1. Dispatch `ticket-builder` with **pointers, not copies**: ticket id/path,
   its bar, owned files, worktree path, fixed point (base sha). It stops at
   green, uncommitted, and reports state, checks run and criteria evidence.
2. Dispatch `ticket-reviewer` with the fixed point, the worktree, the ticket
   pointer, the same bar, the initiative goal, and the standards files to read
   (`CLAUDE.md`, `AGENTS.md`, `CODING_STANDARDS.md`, `docs/agents/workflow.md`,
   whichever exist — the reviewer does not load project memory by itself).
   Fresh context: it never receives the builder's account, only the artifact.
   A reviewer that errors, times out or returns no report did not review:
   dispatch it once more. If it fails again, the ticket lands **not
   reviewed**, with a follow-up issue — never as a clean review.
3. Send the numbered findings to the **same builder** with `SendMessage`. Its
   build context is intact, so the fix is cheap. It sorts each finding into
   fix / contest / escalate / decline (rules in its agent file), commits once
   and replies with the sort per number.

Do not spawn a fresh agent to act on findings — it has to re-derive the whole
ticket to change a line. The builder does not run `/code-review`; the
reviewer is the review. One exchange is the budget: findings still standing
go to step 5 as a follow-up issue, not another round.

Builder outcomes:
- `blocked` with a design question → ask the user (batch with other
  questions), then continue the same builder.
- `dropped` → record the evidence; no review, no follow-up.
- Builder died mid-run → dispatch once more with: "inspect the worktree, git
  log and ticket state first; do not repeat completed external actions."

During the run:
- At every wave transition, post a TL;DR from `run.md` (ticket → state, what
  is next, needs-you) without being asked.
- **Goal check** per wave: does the landed work move the goal line? Two
  tickets in a row that do not, or a trade-off the spec never sanctioned
  (debug access, observability, safety), → stop and ask.
- **Usage floor**: before each wave, if the usage line in context is below
  the floor, finish the running pairs, land them, write the handoff, stop.
- New input mid-run (a rename, a bug the user spots, a new ask) becomes a
  ticket in a later wave, unless it corrects a ticket still being built.
- Long commands run in the background; never poll in a foreground loop.

## 5. Land

1. Merge each finished ticket branch into the run branch in dependency order.
   A conflict goes back to that ticket's builder ("merge the run branch into
   yours, resolve, re-run checks"), not to a fresh agent.
2. Run the full test suite once over everything merged.
3. **Branch gate:** run the `code-review` skill over the run base…HEAD diff.
   Must-level findings go to the owning builder if still alive, else become
   follow-up tickets. Clean runs still get this gate: per-ticket reviews miss
   cross-ticket defects.
4. Grep the diff for new `shortcut:` markers; list them.
5. Ship per **Ship** in `workflow.md` — commit, push, PR, pipeline, deploy,
   served-commit check — and nothing beyond it. Watch CI to its end in the
   background.
6. Update the tracker for every ticket, as part of landing: comment with
   criteria → evidence, landed sha, CI run; then close or move to review per
   the **Close ritual**. A criterion only proven locally, not on the target
   environment, gets a follow-up ("unproven on <env>").

## 6. Report

- One line per ticket: landed / landed-with-issue (issue id) / blocked
  (reason) / dropped (evidence).
- Every escalated finding: it needs the user's knowledge, not only approval.
- A **review walkthrough**: what to look at, where, in what order, to accept
  the run in a few minutes (URL, screen, command).
- Pushed or not; next ready ticket.
- Close with the `handoff` close lines (`Safe to /clear: …`).

## Resume

Read `run.md`, then reconcile: `git worktree list`, branch heads, tracker
states, PR/CI state. Report differences in one short list. Continue the same
builders by id where they still exist; otherwise re-dispatch with the
recovery note. Never redo a landed ticket or a completed external action.
