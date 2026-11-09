---
name: implement
description: "Implement one ticket (or a spec that is really one ticket) end to end in this session: build test-first, review, commit, ship per the repo's policy, update the tracker."
argument-hint: "<ticket id | path | description>"
disable-model-invocation: true
---

## 1. Start

- Read `docs/agents/workflow.md` (missing → run `repo-setup` first) and the
  newest `.local/handoffs/` file if it concerns this ticket.
- Fetch the ticket from the tracker and state its id and title before
  anything else. Ambiguous reference → ask.
- Pin the fixed point: `git rev-parse HEAD` on a clean tree.
- Ask everything you will need **now**, in one numbered list with recommended
  answers: open design choices, tokens or rights the ship step needs, landing
  choice if `workflow.md` leaves it open. Say upfront which later step will
  need the user ("I'll call you for the PAT at the publish step").

## 2. Build

Follow the **Scope** and **Build and verify** rules in
`~/.claude/agents/ticket-builder.md`: original ticket wins, callers in
scope, reuse first, never-cut list, `tdd` at the agreed seams, stuck tripwire,
the verify commands from `workflow.md` (fast check and single tests often,
full suite once at the end).

## 3. Review

Run the `code-review` skill against the fixed point. Fix every finding that
holds; for one you reject, say why with evidence. Re-run the affected checks.

## 4. Land

Follow **Ship** and **Close ritual** in `workflow.md`, nothing beyond them:
commit (only this ticket's files), then push / PR / pipeline / deploy as the
policy says. Watch CI or the pipeline in the background to its end. Then
update the ticket: criteria → evidence, commit sha, CI run; close or move to
review. A criterion proven only locally gets a follow-up ("unproven on <env>").

## 5. Report

Criteria with evidence, pushed or not, what the user should look at to accept
it (URL, screen, command), follow-ups filed. End with the `handoff` close
lines (`Safe to /clear: …`).
