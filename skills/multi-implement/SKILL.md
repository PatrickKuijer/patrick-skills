---
name: multi-implement
description: "Implement a set of tickets in parallel, one subagent each."
disable-model-invocation: true
---

Take a spec or a set of tickets to done. You own the **bar** and the
**slice**; subagents own the building and their own review.

One ticket, or a spec that is really one ticket: run `/implement`, stop here.

## 1. Set the bar

Pin one **bar** per ticket before dispatching — the standard its result is
compared against. Named, fetchable, comparable:

- An exemplar already in this repo — the module, test file, or endpoint the
  new work should read like. Name the path.
- The ticket's acceptance criteria, rewritten as pass/fail checks.

Adjectives ("clean", "production quality") leave the review arguing with
itself; name a thing instead.

Every claim a comment or doc makes must be measured this session or cited to
a file:line. Unmeasured assertions are the defect this repo keeps shipping.

Show the user the bar list and take corrections before dispatching.

## 2. Slice the fan-out

Fan out **decoupled** tickets in parallel. Run **coupled** tickets — same
files, or blocking each other in the tracker — in sequence. The tracker's
ready/blocked graph is the slice: what is ready is the fan-out.

Give each parallel builder its own git worktree. A shared tree means shared
incremental build state, and concurrent `tsc --build` invents errors that
cost a builder a round to chase.

## 3. Build

Each ticket is worked by a **pair**: a `ticket-builder` and a
`ticket-reviewer`. One exchange between them, then it lands.

1. Dispatch `ticket-builder` with its ticket, its bar, and the files it owns.
   It stops at green tests, **uncommitted**, and reports the fixed point its
   diff starts from.
2. Dispatch `ticket-reviewer` with that fixed point, the ticket, and the same
   bar. Fresh context — it never receives the builder's account of the work,
   only the artifact. A reviewer that errors, times out or returns no report
   did not review: dispatch it once more. If it fails again, the ticket lands
   **not reviewed**, with a follow-up issue — never as a clean review.
3. Send the findings back to the **same builder** with `SendMessage`. Its build
   context is intact, so the fix is cheap and it already knows why the code is
   shaped that way. It sorts every finding into one of four, then commits once:
   - **fix**: the finding holds; change the code.
   - **contest**: the finding is wrong, and the builder cites evidence the
     reviewer could have read — a file:line, a test, the ticket, the bar.
   - **escalate**: the finding is wrong, but the evidence lives outside every
     file the reviewer could read (a team convention, a verbal decision). The
     code stays; the finding goes to the user in step 4.
   - **decline**: a nit, recorded and left.

   A contest stands on checkable evidence; without it, the finding is a fix or
   an escalate. The builder wrote the code, so its wish to contest is not
   evidence. Add a comment or doc line only when a human reader needs it; a gap
   that only the zero-context reviewer has is an escalate.

Do not spawn a fresh agent to act on findings — it has to re-derive the whole
ticket to change a line, which is the most expensive way to land the cheapest
fix.

The builder does not run `/code-review`; the reviewer is the review. Do not
review a diff twice.

One exchange is the budget. Findings still standing after the builder has
answered them go to step 4 as a follow-up issue in the project's issue
tracker — not another round.

## 4. Land

Run the full test suite once over everything merged.

A ticket the builder could not bring to green, or that lands carrying known
findings, gets a follow-up issue in the project's issue tracker — not another
round. Report each ticket as landed, or as landed-with-issue naming the issue.
List every escalated finding with the report: it needs the user's knowledge,
not only their approval.
