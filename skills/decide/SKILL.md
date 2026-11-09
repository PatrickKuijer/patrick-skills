---
name: decide
description: "Take a decision ticket from open question to recorded decision: load what is already decided, grill only the gaps, then write the ADR / glossary / spec changes, comment, close and commit only those files. Use for 'lets work #N' on a decision or design ticket, 'grill the gaps', 'record the decision', 'had the meeting, record what we decided', or a devil's-advocate comparison."
argument-hint: "<ticket id> | record <decision text> | advocate <alternative>"
---

## 1. Load what is already decided

Read the ticket with comments, its parent/map ticket, the ADRs and research it
links or that share its terms, the glossary, and `docs/agents/workflow.md`.
Open with three short lists: **already decided** (with ADR/ticket pointer),
**open questions**, **out of my reach** (needs someone other than the user).

## 2. Grill the gaps only

Use the `grilling` skill's protocol, with these rules on top:

- Ask only about the open questions. Never re-ask what an ADR settles.
- Number every question; give lettered options and a recommended answer,
  worded so "ok" accepts it. Expect replies like `1 ok 2 b 3 a but X 4 ?`.
- Plain language. Define any term of art the first time it appears; if the
  user asks what a word means, use their word from then on.
- Accepted non-answers: `defer`, `park for <person>`, `not my call`. Record
  each as **Open** with owner and reason; do not push for an answer.
- Facts are your job: look them up (code, Confluence, research notes) instead
  of asking the user.

`advocate <alternative>`: write the shared understanding as it would be under
the alternative and show only the diff against the current one.

## 3. Confirm

Write the shared understanding as numbered decisions plus Open items. Wait for
an explicit confirmation ("confirmed", "ok", "go"). Corrections loop back here.

## 4. Record

`record <decision text>` (e.g. after a meeting) starts here.

- **ADR** only when the decision is hard to reverse AND surprising without
  context AND a real trade-off. Otherwise the ticket comment carries it.
- **Glossary**: new or changed terms, with `_Avoid_:` synonyms.
- **Spec / schema / overview** rows the decision changes.
- Parked items: file one decision-needed ticket per owner under the map/parent,
  if the user wants them filed.
- Run the docs gates from `workflow.md`.

## 5. Close

Follow the **Close ritual** in `workflow.md`. Default when it is silent:
commit only the files this decision touched (`<id>: <decision in five words>`),
comment the decision with pointers on the ticket, close it, add a pointer on
the map/parent ticket, no push. Then end with the `handoff` close lines
(`Safe to /clear: …`).
