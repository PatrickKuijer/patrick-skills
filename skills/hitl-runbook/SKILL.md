---
name: hitl-runbook
description: "Prepare and verify work only a human can do: portal steps, rights and permissions, IT requests, credentials, sign-ins. Produces the full rights matrix up front, portal click-paths, an IT request list, then verifies read-only after the user says done. Use for 'me job', 'show me the instructions for X', 'which rights do I need', 'list of permissions and paths', 'what do I ask IT', or after 'done' / 'I ran it' / 'try again'."
argument-hint: "<ticket id | script path | goal>"
---

The user is the actuator here; your job is to make each human step one clean
pass and to prove afterwards that it worked.

## 1. Read before anyone runs anything

Read the ticket, the script or pipeline it involves, and the repo's rights file
(`Rights.md` or what `docs/agents/workflow.md` names). Work out **every**
permission the whole job needs before the first step, so rights are not found
one failure at a time.

## 2. Rights matrix

Update the rights file with one row per need, Azure RBAC and Entra/Graph in
separate tables:

| step | identity (user / SP / managed identity) | scope path | role or permission | have | IT grants | one-time / per phase | why |

New rows are marked **new**. The `why` column is the memory: it stops a later
session from undoing or contradicting a grant.

## 3. Instructions

- Default to **portal click-paths**: `Portal › <blade> › <section> › <button>`,
  exact names, which account and tenant to be signed in with.
- A command only when there is no portal path or the user asks: one line, in
  the repo's shell (PowerShell unless `workflow.md` says otherwise),
  non-interactive or device-code auth (scripted interactive MFA logins trip
  security alerts), output teed to `.logs/<step>.txt`
  (`2>&1 | Tee-Object .logs/<step>.txt`) so you can read the result instead of
  the user pasting it.
- Secrets never go through chat: write placeholders and `.env.example`, and
  name the human step that fills them.

## 4. IT request

For everything in the **IT grants** column: one short message the user can
forward — permission, scope path, why, ticket — no commands. Language per the
**Language** section of `workflow.md`. Track it as a human/IT-wait ticket.

## 5. Verify after "done"

When the user says done, prove it read-only: role assignment list, a Graph
query, the GET that failed before, the pipeline rerun. Tick the matrix, comment
the evidence on the ticket, and move on. Still failing → name exactly what is
missing; never ask the user to "try again" without a new fact.
