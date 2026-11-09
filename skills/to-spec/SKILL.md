---
name: to-spec
description: "Turn the current conversation into a spec and publish it to the repo's tracker or a local spec file: no interview, synthesis of what was already discussed."
argument-hint: "[local] [prototype]"
disable-model-invocation: true
---

Synthesize what this conversation already settled. Do not interview; a gap
you cannot fill goes under **Open decisions** with an owner.

## Process

1. Read `docs/agents/workflow.md` for the tracker (missing → `repo-setup`).
   Explore the code the spec touches if you have not. Use the glossary's terms
   and respect ADRs in the area.
2. Sketch the test **seams**: prefer existing ones, the highest one possible,
   as few as possible. One line each on what it catches and what it misses.
   Check the seams with the user before writing.
3. Write the spec with the template, then publish:
   - tracker → one issue labelled agent-ready (per `workflow.md`), or
   - `local` argument or local tracker → `.local/<topic>/spec.md`, with
     `.local/` in `.git/info/exclude`.
4. End with the exact next commands, so the next session needs no pasting:
   `/spec-check <spec ref>` then `/to-tickets <spec ref>`; and the `handoff`
   close lines.

## Template

```markdown
## Goal
One sentence: the outcome that makes this spec worth doing. Builders and
reviewers measure every ticket against it.

## Problem
From the user's perspective.

## Solution
From the user's perspective.

## Behaviour
Numbered stories or requirements — as many as the behaviour needs, no more:
"As a <actor>, I want <feature>, so that <benefit>", or for machine/PLC work
"<module> shall <behaviour> when <condition>".

## Decisions
Modules built or changed and their interfaces, schema and API contracts,
state machines, architectural choices. Name stable domain identifiers (FB,
IO tag, endpoint, table) when a decision is about them; leave out file paths
and line numbers, they go stale. A prototype snippet that encodes a decision
better than prose (state table, schema, type) goes inline, trimmed, marked
as from the prototype.

## Testing
The seams from step 2, what a good test checks here (external behaviour,
expected values from this spec), prior art in the repo.

## Out of scope

## Open decisions
<question> — owner — what it blocks.

## Size
product | prototype  (a prototype spec gets few, coarse tickets)
```
