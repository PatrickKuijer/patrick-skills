---
name: to-tickets
description: "Break a spec, plan or the current conversation into tracer-bullet tickets with blocking edges, split into agent-ready and human lanes, and publish them to this repo's tracker (beads, GitHub issues, or local markdown)."
argument-hint: "<spec ref | epic id> [parent id]"
disable-model-invocation: true
---

## 1. Gather

- `docs/agents/workflow.md` for the tracker and labels (missing → `repo-setup`).
- The spec or plan: fetch a passed reference with its comments; otherwise use
  the conversation. A `spec-check` report for it, if one exists.
- The target repo is the one you are in. Work that belongs to another repo:
  say so and stop — never file into another repo's tracker from here.
- Explore the code the work touches. Look for prefactoring that makes the
  change easy: "make the change easy, then make the easy change".

## 2. Draft tracer bullets

- Each ticket cuts a narrow but complete path through every layer it needs
  (schema, API, UI, PLC logic, tests): vertical, never one layer alone.
- Each is demoable or verifiable on its own and fits one fresh context window.
- Prefactoring comes first, as its own ticket.
- Spec `Size: prototype` → few, coarse tickets; say how many you would cut
  for a product build instead.

**Wide refactors** (one mechanical change whose blast radius breaks callers
everywhere at once) are the exception: expand (add the new form beside the
old), migrate call sites in batches sized by blast radius (each batch its own
ticket, blocked by the expand), contract (delete the old form, blocked by
every batch). If batches cannot stay green alone, they share an integration
branch and block a final integrate-and-verify ticket.

Write each ticket for a builder with no other context: behaviour, not
procedure; criteria each independently checkable; durable wording that
survives refactors.

## 3. Quiz the user

Show a numbered list — title, blocked by, lane (`agent` / `human: <action>`),
what it delivers — then the critical chain and the waves with their width.
Ask, in one message: granularity right? edges right? merge or split any?
parent ticket (default: the spec's issue)? Iterate until approved; publish
on an explicit yes.

## 4. Publish

Use the tracker verbs from `workflow.md` (reference:
`~/.claude/skills/repo-setup/references/trackers.md`). Blockers first, so
edges reference real ids; native blocking links where the tracker has them.
Label `human` only where a person must act or validate; everything else is
agent-ready. Do not close or edit the parent.

```markdown
# <id>: <title>

**Goal link:** the spec goal this ticket moves.
**What to build:** end-to-end behaviour from the user's perspective.
**Bar:** an exemplar in the repo to read like (module/FB/test), if one exists.
**Touches:** the modules or areas expected to change (not file paths).
**Blocked by:** ids, or "none".
**Lane:** agent | human: <the exact human action>

## Acceptance criteria
- [ ] <criterion> — proven by <command / test / observation>

## Out of scope
- <what a builder might be tempted to do but must not>
```

Local tracker: one file per ticket, `.local/<topic>/issues/NN-<slug>.md`,
numbered in dependency order, `Status: ready-for-agent` or `ready-for-human`.

End with the next command (`/multi-implement <epic or folder>`, or
`/implement <id>` for a single ticket) and the `handoff` close lines.
