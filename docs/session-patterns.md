# Session patterns (2026-10-10 → 2026-11-09)

What 30 days of Claude Code sessions say about how the work actually runs,
and which skill answers each pattern.

## Method

- `scripts/digest-sessions.py` condensed 187 top-level transcripts (520 MB,
  plus 405 subagent transcripts) into one small digest each: metadata, slash
  commands, skills, agents, tool counts, every user prompt in order, the last
  assistant text.
- Three analysts each read a third of the digests (by date), labelled every
  session with one primary category from a fixed list, and pulled patterns,
  friction and the ideal skill behaviour per category. Raw transcripts were
  only opened to confirm specific corrections.
- 186 sessions categorized (the session that built this repo excluded).
  Desktop tabs reused with `/clear` and forks make one conversation span
  several digests, so counts are of transcripts, not of tasks.

## Categories

| Category | 23 Sep–26 Oct | 23 Oct–2 Nov | 2–9 Nov | Total | Shape |
|---|---:|---:|---:|---:|---|
| implement | 4 | 13 | 14 | **31** | bimodal: single tickets in 4–8 prompts; orchestrated runs of 11–17 prompts, 15–30 subagents, 1–5 days, 1–3 compactions |
| plan-spec | 10 | 8 | 8 | **26** | grill → ADR rituals, to-spec / to-tickets, "propose me a plan" |
| backlog-status | 9 | 6 | 5 | **20** | the cleanest loop: `/clear`, one id, verdict with evidence, one-word decision (1–4 prompts) |
| research-review | 6 | 3 | 11 | **20** | second opinions, devil's advocate, PR reviews; almost always ends in "commit it" |
| tooling-meta | 10 | 3 | 6 | **19** | skills, mods, permissions, usage limits |
| debug-ops | 8 | 6 | 3 | **17** | Azure/Entra rights, pipelines, tunnels, bpa-vm; bimodal 1–3 or 15–21 prompts |
| docs-comms | 7 | 4 | 4 | **15** | meeting prep / recap, decks, management video, Dutch mails |
| automated | 4 | 5 | 5 | **14** | harness runs and `/clear` stubs — ignore |
| quick-question | 5 | 2 | 1 | **8** | always clean |
| domain-plc | 1 | 3 | 2 | **6** | Confluence lookups, ST diagnosis, OpenPLC probes |
| prototype | 2 | 4 | 0 | **6** | first versions too busy; long VM demo feedback rounds |
| kb-curation (proposed) | 4 | – | – | **4** | keeping the knowledge repo in line with decisions |

## Per category: friction → what the skillset now does

### implement (31) → `multi-implement`, `implement`, `ticket-builder`, `ticket-reviewer`

| Friction seen | Answer |
|---|---|
| "status?", "Tldr status update?", `/agents-info` ×~15 — status is pulled | TL;DR pushed at every wave from `run.md` |
| runs lose state on compaction / `/clear`; "you've already started but paused" | `.local/runs/<slug>/run.md` + **Resume** section |
| landing policy restated every run ("small PRs to main", "merge, no PR", "keep it local") | **Ship** in `docs/agents/workflow.md`, read by both implement skills |
| "update the ticket(s)" is always a separate prompt | tracker update is a landing step |
| external blockers surface mid-run (PAT, Graph rights, VM down, admin creds) | preflight: environment commands + one batched needs-you list + AFK verdict |
| ~41 h of approval waits in one run; "I'm off, expect approvals?" | AFK verdict lists commands likely to need approval before the user leaves |
| scope drift unflagged ("2 days into fixing the compiler… none related to bluemotion", lost debugger access) | goal line in the spec, per-wave goal check, reviewer **Goal** section, never-cut list includes debug access |
| branch-wide review after a run found what per-ticket reviewers passed | **Branch gate** (`code-review` over the whole run) |
| Sonnet builders stalled; "next time use an opus agent as sub" | agents pinned to Opus (builder medium, reviewer high); model overridable per run |
| `C:\git` vs `C:\Git` broke worktrees | worktree paths from `git rev-parse --show-toplevel` |
| smoke test never proved the key criterion | criteria rewritten as pass/fail with the proving command; "unproven on <env>" follow-up |
| "you are just the orchestrator" | orchestrator never edits product code |

### plan-spec (26) → `decide`, `to-spec`, `spec-check`, `to-tickets`

- The decision ritual repeats almost verbatim: "lets work #N" → grill →
  "Confirmed… write ADR, glossary, spec, run gates" → "commit only #N files,
  comment, close, pointer on map #13, don't push". → `decide` makes it the default.
- Answers are terse and numbered ("1 ok 2 b 3 a but…"); jargon stalls ("rungs?");
  some decisions are "not my call". → numbered questions with recommendations,
  plain language, `defer` / `park for <person>` recorded as Open with owner.
- `/to-spec` → `/to-tickets` handoff done by pasting; tickets filed in the wrong
  repo's tracker; too many tickets for a prototype. → to-spec prints the next
  commands; to-tickets refuses cross-repo filing; `Size: prototype`.
- Ambiguous tickets reach builders. → `spec-check` (fresh read-only reader) in between.

### backlog-status (20) → `status`

Ask from any repo, one id or "what's next", evidence-backed closes, IT-blocked
work grouped per person with a drafted ask, a time-budget mode ("15 minutes of
brainpower left"), two queues: agent-ready vs needs-you.

### research-review (20) → `code-review` (reviews), Matt's `research` (kept)

PR reviewed three times in one afternoon from two repos → review ledger in
`.local/reviews/`. Review in chat, not PR comments, by default. Research skipped
a sibling repo → **Related repos** in the workflow file.

### debug-ops (17) → `hitl-runbook`, `diagnosing-bugs`

Rights discovered one failure at a time; "list of permissions and paths, not the
cmd"; scripted MFA login flagged by security; user pastes all output back. →
rights matrix before the first run, portal click-paths, device-code auth,
`Tee-Object .logs/<step>.txt`, read-only verification after "done".

### docs-comms (15) → `team-comms`

Chat English, team artefacts Dutch with English industry terms; "no blue
renamer"; "it's noise", "feels AI generated"; one point of a long feedback
message missed; video rendered before the plan was agreed. → language and
audience rules, no-noise test, feedback as checklist, outline → preview → render.

### tooling-meta (19), quick-question, automated, domain-plc, prototype

Left to existing skills (`framework-conventions`, `review-function-block`,
`glossary`, `prototype`, mods). Two concrete follow-ups the data supports but
this repo does not build yet: a **bpa-vm** skill (stack registry, deploy +
served-commit check, keep-alive tunnel) and a **plc-probe** skill (generate an
ST probe program and parse the pasted result table).

## Cross-cutting patterns

1. **Front-load questions, then run unattended.** "any questions upfront? ask
   them before running off", "record those decisions upfront", "ready for an afk
   overnight run?". Every long skill now has one batched question step and an AFK verdict.
2. **Context is carried by hand.** Background briefs, pasted last messages,
   `%TEMP%` handoffs, "give me a sign when I can clear" (23 `/clear`s in one
   month of one terminal). → `handoff` writes `.local/handoffs/`, prints `Safe to /clear`,
   and every skill reads the newest handoff on start.
3. **Trackers differ per repo and changed mid-month** (beads, GHE issues +
   Project fields, local `.local/**/issues`, `tickets/`). `GH_HOST` on almost
   every `gh` call. → one `workflow.md` per repo, one verb table.
4. **Parallel sessions collide** (uncommitted work on another session's merged
   branch, lock files on bpa-vm, a stale week-old worktree hiding specs on main).
   → handoff checks branch state before declaring safe; multi-implement flags claimed tickets.
5. **The human acceptance loop is a real step**: build → review on the VM →
   bullet feedback → tickets → run → deploy. → the review walkthrough at the end of every run.
6. **Cost is first-class**: `/usage-limit` floors, Sonnet-high builders when the
   weekly runs low, caveman. → usage floor per run, model override.
7. **Patrick catches goal and trade-off errors the agents miss.** → goal line,
   goal check, reviewer goal section.
8. **Numbered, terse, typo-heavy replies.** Skills number every question and
   accept "1 ok 2 b".

## Re-running

```powershell
python -I scripts/digest-sessions.py $HOME/.claude/projects <out dir> <since YYYY-MM-DD>
```

Then hand the digests to analysts with the category list above.
