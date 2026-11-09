# Tracker command sets

Use the set that matches `kind:` in `docs/agents/workflow.md`. Every skill
speaks in the same verbs; this file maps them to commands.

| Verb | beads (`bd`) | GitHub issues (+ Project) | local markdown |
|---|---|---|---|
| list ready | `bd ready` | `gh issue list -l ready-for-agent` (or Project Status = Ready) | files whose `Status:` is `ready-for-agent` and whose blockers are all done |
| list blocked | `bd blocked` | issues with open `Blocked by` / native blockers | files with an open blocker |
| show | `bd show <id>` | `gh issue view <n> --comments` | read the file |
| create | `bd create "<title>" -d "<body>" [-p N] [--parent <id>]` | `gh issue create -t -b [-l] ` then link | write `<dir>/issues/NN-<slug>.md` |
| blocker edge | `bd dep add <id> <blocker>` | native "blocked by" if the host supports it, else a `Blocked by: #n` line | `Blocked by:` line |
| comment | `bd comments add <id> "<text>"` | `gh issue comment <n> -b` | append under `## Log` |
| claim | `bd update <id> --status in_progress` | assign self / Project Status = In progress | `Status: in-progress` |
| to review | `bd update <id> --status review` (or label) | Project Status = In review | `Status: in-review` |
| close | `bd close <id> -r "<reason>"` | `gh issue close <n> -c "<reason>"` | `Status: done` + reason |

The command columns are starting points, not gospel: CLIs change. Confirm each
form once with `--help` while writing the workflow file and record the form
that worked there; runtime skills use the workflow file, not this table.

GitHub Enterprise: prefix every `gh` call with `GH_HOST=<host>` (PowerShell:
`$env:GH_HOST='<host>'; gh ...`). Project fields need `gh project item-edit`
with field and option ids; resolve them once with `gh project field-list` and
record them in the workflow file.

Local tracker layout: `.local/<topic>/spec.md` + `.local/<topic>/issues/NN-<slug>.md`,
with `.local/` in `.git/info/exclude`. Create that layout when the user asks
for local tickets.

Never file into a tracker that belongs to another repo than the one being
worked. If the work belongs elsewhere, say so and stop.
