# patrick-skills

Personal Claude Code skills and agents, versioned here and linked into
`~/.claude`. Built on 2026-11-09 from five public skill repos and 30 days of
real sessions.

## The flow

`to-spec` → `spec-check` → `to-tickets` → `multi-implement` (or `implement`)
→ `status`, with `decide` for decision tickets, `hitl-runbook` for steps only
a human can do, `team-comms` for anything written for other people, and
`handoff` at every `/clear`. Every skill reads the repo's
`docs/agents/workflow.md`, written once per repo by `repo-setup`.

| Skill | Use it for |
|---|---|
| `/multi-implement <epic\|ids\|folder>` | a set of tickets: preflight, bars, waves of builder+reviewer pairs, branch gate, land, report |
| `/implement <id>` | one ticket end to end |
| `/to-spec`, `/to-tickets` | conversation → spec → tracer-bullet tickets (agent vs human lanes) |
| `spec-check` | fresh read-only readiness check of a spec / tickets |
| `status` | what's closable, agent-ready, waiting on you or others; the next thing |
| `decide <id>` | grill only the gaps, record ADR/glossary, close the ticket |
| `code-review <ref>` | two-axis review (standards, spec) with a strict finding contract |
| `diagnosing-bugs` | red-capable loop first, then hypotheses |
| `hitl-runbook` | rights matrix, portal paths, IT asks, verify after "done" |
| `team-comms` | meeting prep/recap, mails, questionnaires, management updates |
| `handoff` | save state, `Safe to /clear`, resume |
| `repo-setup` | write `docs/agents/workflow.md` for a repo |

Agents: `ticket-builder`, `ticket-reviewer` (isolated: no project memory,
read-only tools), `spec-checker`.

## Install

```powershell
pwsh scripts/install.ps1 -WhatIf   # dry run
pwsh scripts/install.ps1
```

Creates a directory junction per skill in `~/.claude/skills` and turns
`~/.claude/agents` into a junction to `agents/`. Whatever it replaces moves
to `~/.claude/skill-backups/<timestamp>/` with a `manifest.txt`; nothing is
deleted. Skills retired in favour of a differently named one are listed in
`skills/RETIRED.txt`. Start a new session afterwards so the skills load.

## Check

```powershell
pwsh scripts/check-skills.ps1
```

Frontmatter, size limit, and `tests/contracts.txt`: load-bearing phrases that
must survive edits.

## Docs

- `docs/sources-overview.md` — the five source repos, categorized
- `docs/session-patterns.md` — 186 sessions categorized; friction → skill
- `docs/skill-map.md` — every skill and agent, and which source each rule came from
- `docs/reviews/` — the full per-repo reviews

## Credits

Adapted, reworded material from mattpocock/skills (MIT), DietrichGebert/ponytail
(MIT), deepseek-ai/dsh-superagent-prototype (MIT), google/elephant-goldfish-model
(Apache-2.0) and microsoft/TokenEconomizer (Apache-2.0). Notices in `LICENSES/`.
