---
name: spec-check
description: "Have a fresh, read-only agent check a spec and/or its tickets for readiness before builders start: can it be paraphrased, does any ticket force a design decision, are criteria pass/fail, does it match the code, is anything reinvented. Use before /to-tickets or /multi-implement, or when the user asks to check, sanity-check or second-opinion a spec or ticket set."
argument-hint: "<spec ref> [ticket refs | tickets folder]"
---

The author of a spec cannot see its gaps: they fill them from memory. A fresh
reader with only the artifact can. This skill runs one such reader.

## 1. Pin the artifact

Resolve the spec and the tickets (tracker per `docs/agents/workflow.md`, or
paths). For tracker items, export them to
`.local/spec-check/<slug>/input/` as markdown so the checker reads files, not
tracker commands. Note the spec's last-edit time.

## 2. Dispatch one `spec-checker`

Start it with a fresh context and give it only:

- the input paths (spec, tickets, the ADRs and glossary the spec cites),
- the repo root to search,
- the report path `.local/spec-check/<slug>/report.md`.

No summary of the conversation, no hints about what you think is wrong: that
is exactly the bias the check exists to remove. If it errors, times out or
returns nothing, dispatch once more; if that fails, report "spec check not
run", never "no findings".

## 3. Triage, then report

Sort each finding as the spec's author:

- **fix** — the gap is real; propose the edit to the spec or ticket.
- **contest** — wrong, with evidence the checker could have read (file:line,
  ADR). A comprehension gap is never contested: if a fresh reader could not
  follow it, the context is missing from the document.
- **escalate** — needs knowledge outside the repo; goes to the user.

Show the verdict, the fixes as one numbered list the user can accept tersely
("all ok", "1 ok 3 no"), and the escalations. Apply accepted fixes to the spec
and tickets. Do not re-run the check for small fixes; offer a re-run only
after a structural rewrite.
