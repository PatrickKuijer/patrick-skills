---
name: status
description: "Backlog and progress check for the current repo: what is closable, what agents can do unattended, what needs the user, what is blocked on others, and the one thing to do next. Use for 'status', 'what's next', 'can we close X', 'which are agent ready', 'any afk work?', 'check the AC of X', 'what's open on X', or when the user has N minutes left."
argument-hint: "[ticket id | epic id | hitl | afk | closable] [time budget]"
---

Read-only until the user answers. The output is a short table and a numbered
action list the user can answer tersely ("1 close 2 p3 3 go").

## 1. Load

- `docs/agents/workflow.md` for the tracker and its commands. Missing → say so,
  run the tracker detection from `repo-setup`, and continue.
- The newest `.local/handoffs/*.md`, if any: it says what was in flight.
- Open items (or only the named id/epic and its children), plus for each: open
  PRs, CI/pipeline state of its branch, and whether its blockers are done.
  For GitHub Enterprise remember `GH_HOST`.

## 2. Verify, don't trust

For every item that looks done, check its acceptance criteria against reality
with read-only commands (merged commit, passing run, deployed state, file
present). Cite the evidence. A criterion you could not check is "unverified",
never "done".

## 3. Classify

| Lane | Rule |
|---|---|
| **Closable** | every criterion verified; give the evidence in one line |
| **Agent-ready (AFK)** | unblocked, criteria are pass/fail, no human step, no open design decision |
| **Needs you (HITL)** | a human must act or decide; write the exact action (portal path, command, question) |
| **Waiting on others** | grouped per person or team (IT, a colleague), each with one drafted ask |
| **Blocked** | names the blocker |
| **Stale** | text contradicts later decisions or code, or untouched while its siblings moved |

Also flag drift: a decision recorded in a ticket comment or meeting note that
never reached the ADRs / overview / glossary.

## 4. Report

1. The table above, one row per item, lanes with no items omitted.
2. **Next:** one recommendation with a one-line reason. With a time budget,
   pick the fastest unblock that fits it.
3. Numbered actions, e.g. `1 close .4 (evidence)`, `2 /multi-implement the 3 AFK
   items`, `3 send IT the 2 asks`. Nothing is closed, reprioritised or filed
   until the user answers; every close carries its reason.

Keep it under ~25 lines of chat. No restating ticket bodies.
