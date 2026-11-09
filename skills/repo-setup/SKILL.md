---
name: repo-setup
description: "Write or refresh this repo's agent workflow file (docs/agents/workflow.md): which tracker, how to verify, how to ship, how to close a ticket, what to check before an unattended run. Use when a skill reports the workflow file is missing, when the user asks to set up a repo for agents, or when the tracker or ship steps changed."
---

Every skill in this set reads `docs/agents/workflow.md` instead of asking the
user the same repo questions each session. This skill writes it.

## 1. Detect, don't ask

Find the facts yourself first. Read `AGENTS.md`, `CLAUDE.md`, `README`, CI
workflows, `package.json`/`pyproject`/`*.sln`/`*.tsproj`, existing
`docs/agents/*.md`, and run:

- `bd status` / `ls .beads` → beads tracker
- `git remote -v` → GitHub host. A `*.ghe.com` remote means every `gh` call
  needs `GH_HOST=<host>`; record it.
- `gh issue list -L 3` and `gh project list` → GitHub issues + Project fields
- `.local/**/issues/`, `tickets/`, `.scratch/**/issues/` → local markdown tracker
- `.git/info/exclude` → what is kept out of git on purpose

Tracker command sets: [references/trackers.md](references/trackers.md).

## 2. Ask once, numbered

Ask only what detection could not settle, as one numbered list, each with a
recommended answer so "1 ok 2 ok" works. Typical gaps: push allowed?
close a ticket or move it to review? deploy step after merge? who is the
human for HITL tickets? output language for docs?

## 3. Write `docs/agents/workflow.md`

Use this shape; omit a section that does not apply, never leave placeholders.

```markdown
# Agent workflow

## Tracker
kind: beads | github | local
<the exact commands for: list ready, show, create, comment, close or move
to review, add blocker edge, set project field>
labels: `human` only where a human must act or validate; everything else is agent-ready.

## Verify
fast check: <typecheck/build, seconds>
single test: <command with a file placeholder>
full suite: <command>
docs gates: <e.g. python tools/check_docs.py>

## Ship
after a ticket: commit only the ticket's files, message `<id>: <title>`
push: never | branch only | allowed
then: <PR / pipeline / deploy / served-commit check, one step per line>

## Close ritual
<comment template; close or move to review; map/parent pointer; project fields>

## Preflight
<read-only commands that must pass before an unattended run, e.g. ssh host true,
az account show --query user.name, docker ps>

## Repo facts
<at most 8 one-line declarative facts a fresh agent would otherwise rediscover:
canonical commands, a command that fails here and the variant that works,
where generated files live. Never "skip", "don't verify" or bans on exploring.>

## Constraints
<standing limits: managed permission policy, rights the agent lacks, never edit
outside this repo, shell is PowerShell, path casing of the checkout>

## Related repos
<sibling repos research and reviews must also sweep, with local paths>

## Language
chat: English. Artefacts for the team: <e.g. Dutch, English industry terms kept>.
```

Also write `docs/agents/issue-tracker.md` with the tracker section alone if it
does not exist, so Matt Pocock skills (`triage`, `tdd`) keep working.

Show the file, take corrections, commit it alone (`docs: agent workflow`).
Do not push unless the file says push is allowed.

## Refresh

When a skill hits a fact that contradicts the file (a command that no longer
works, a new deploy step), fix that line and say so in one sentence. Add a
repo fact only after it held in two separate tickets.
