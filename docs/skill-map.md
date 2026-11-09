# Skill map

What each skill in this repo is, what it replaced, and where every load-bearing
rule came from. Sources: **P** = Patrick's own skills/agents (Sep–Nov 2026),
**M** = mattpocock/skills, **E** = google/elephant-goldfish-model,
**Y** = DietrichGebert/ponytail, **T** = microsoft/TokenEconomizer,
**D** = deepseek-ai/dsh-superagent-prototype, **S** = session analysis
(`session-patterns.md`). Full source reviews: `docs/reviews/`.

## The flow

```
            repo-setup ──► docs/agents/workflow.md  (read by every skill below)
                                   │
 decide ◄── grill ── to-spec ──► spec-check ──► to-tickets ──► multi-implement ──► status
   │                    │            │               │          │  ticket-builder     │
   └── ADR / glossary   └ Goal line  └ spec-checker  └ lanes    │  ticket-reviewer    │
                                                                │  code-review (gate) │
                                     implement (one ticket) ────┘                     │
 hitl-runbook (human steps) · team-comms (people) · diagnosing-bugs (bugs)            │
 handoff ◄──────────── every skill ends with "Safe to /clear" ◄───────────────────────┘
```

## Skills

| Skill | Kind | Replaces | Knowledge extracted, by source |
|---|---|---|---|
| **multi-implement** | user, orchestrator | P multi-implement | **P**: bar, decoupled/coupled slicing, worktree per builder, builder+reviewer pair, SendMessage to the same builder, fix/contest/escalate/decline, one-exchange budget, failed reviewer = not reviewed. **D**: bar restates never extends; pass pointers to the original ticket; `dropped` state; builder crash recovery note; push a TL;DR, never poll; stop by impact. **M**: fresh context per subagent; merge run branch into ticket branch on conflict; phase boundaries. **E**: reviewer gets standards files explicitly because it loads no project memory. **T**: usage floor; repo facts for builders. **S**: preflight + batched questions + AFK verdict, `run.md` + Resume, goal check, branch gate, tracker update at landing, review walkthrough, Windows path casing, orchestrator never builds. |
| **implement** | user | P/M implement | **M**: echo ticket id+title, tdd at seams, typecheck/single tests often, full suite once, code-review, commit. **S**: questions up front and "I'll call you for X at step Y", ship + close per workflow, "unproven on <env>" follow-up. Build rules shared with ticket-builder. |
| **to-spec** | user | P/M to-spec | **M**: synthesis not interview, seams first (highest, fewest), template, prototype snippets inline. **M** (upstream): seam note "catches / misses". **E**: Goal line every ticket is measured against. **S**: stories "as many as needed" (not LONG), PLC requirement form, stable domain identifiers allowed, local `.local/<topic>/spec.md`, `Size: prototype`, prints next commands. |
| **to-tickets** | user | P/M to-tickets | **M**: tracer-bullet slices, one fresh context window, prefactor first, expand–migrate–contract, quiz on granularity/edges, frontier. **M** AGENT-BRIEF: behavioural not procedural, independently checkable criteria, out of scope. **D**: never file into another repo's tracker. **S**: agent vs human lanes (`human` only where a person acts), critical chain + wave width, Goal link, Bar and Touches lines for multi-implement, prototype sizing, tracker verbs. |
| **spec-check** | model | new | **E**: fresh read-only goldfish reviewer with artifact-only diet, failed reviewer ≠ zero findings, author triage (comprehension gaps are never contested). **D**: three-fact readiness test. **S**: ambiguous tickets burned builder rounds. |
| **code-review** | model | M code-review | **M**: two axes in parallel fresh subagents, fixed-point precheck, spec discovery order, Fowler smell baseline overridden by repo, never merge/rerank axes. **Y**: no case → no finding, priority order, read callers, `shortcut:` is a decision, numbered, Verdict + Not checked. **D**: per-criterion PASS/FAIL/UNVERIFIED, bot output is fallible. **E**: review ledger with settled/reopened findings (simplified convergence rules). **S**: PR reviewed 3× → ledger; review in chat by default; ST and glossary hooks. |
| **diagnosing-bugs** | model | M diagnosing-bugs | **M** (upstream, newer than the local copy): red-capable loop gate, minimise, falsifiable ranked hypotheses, tagged instrumentation, seam finding, diff-against-pristine. **T**: stuck check ("materially different hypothesis, do not stop"). **S**: PLC/infra loop recipes (xSTunit/TcUnit, probe program, trace replay, read-only az/gh). |
| **status** | model | new | **S**: the `/clear` → one id → verdict → decision loop, lanes (closable, AFK, HITL, waiting-on-person, blocked, stale), time-budget mode, drift flag. **D**: evidence for every close; one recommendation. **Y**: unverified ≠ done. |
| **decide** | model | new (uses M grilling) | **M**: grilling frontier rounds, recommended answers, "yes accepts the recommendation", facts are the agent's job, ADR gate (hard to reverse + surprising + trade-off), glossary `_Avoid_`. **E**: author decides, park instead of forcing. **S**: the decision ritual verbatim, gap-only, plain language, `park for <person>`, devil's-advocate diff, record-after-meeting mode, commit only touched files, no push. |
| **handoff** | model | M handoff | **M**: pointers not copies, suggested skills, redaction. **D**: resume = inspect state, never repeat external actions. **S**: in-repo `.local/handoffs/` instead of `%TEMP%`, `Safe to /clear: yes/no`, paste-ready next prompt, branch-collision check, auto-resume. |
| **repo-setup** | model | new (coexists with M setup-matt-pocock-skills) | **M**: per-repo agent config in `docs/agents/`, tracker docs. **T**: repo facts rules (declarative, capped, no "skip/verify", promote after repeated confirmation). **D**: authority order (tool/hook facts > skill text). **S**: tracker per repo, GH_HOST, ship profiles, close rituals, preflight commands, constraints, related repos, language rule. |
| **hitl-runbook** | model | new | **S**: rights found one failure at a time, portal paths not CLI, scripted MFA flagged, IT request lists, Rights.md as the checklist, "done → verify". **D**: one structured human action at a time; blocker with evidence and missing prerequisite. |
| **team-comms** | model | new | **D**: attention rules ("would deleting this stop the reader from acting?"), one question at a time. **E**: claims must match evidence. **M**: to-questionnaire ("grill the send"). **S**: language rule, audience vocabulary, no invented brands, banned noise, feedback as checklist, outline → preview → render, never send. |

## Agents

| Agent | Replaces | Knowledge extracted |
|---|---|---|
| **ticket-builder** (Opus, medium) | P stub (1 line) | **P**: stop green + uncommitted, four-way finding sort, commit once. **Y**: scope = callers/tests/fixtures/config/exports, fix once in shared code, reuse ladder, never-cut list, `shortcut:` marker, "skipped / not checked / risk". **D**: original ticket wins, ready/blocked/failed/dropped, "tests actually run", never ready with a check still running, pause by impact not by failing tests, crash recovery. **T**: stuck tripwire, counters in the report. **M**: tdd at seams, expected values from an independent source. **S**: PLC never-cut items (interlocks, alarms, calibration, debug access). |
| **ticket-reviewer** (Opus, high) | P stub (1 line) | **E**: `omitClaudeMd: true` + restricted tools, incomplete review instead of verdict. **Y**: finding contract (concrete case, priority order, Must/Should/Nit numbered, Verdict, Not checked), read callers, marked shortcut is a decision. **D**: per-criterion verdict including passes, bot output fallible. **M**: spec axis questions, run the checks yourself. **T**: high confidence for blocking findings, pass when evidence says met. **S**: goal / trade-off section, `review-function-block` for ST. |
| **spec-checker** (Opus, high) | new | **E**: paraphrase first, zero-decision rule, fresh-engineer test, doc-vs-code accuracy (contradiction = blocker, proposed files are not findings), reuse search, `[file:symbol]` citations, explicit nothing-found output. **D**: three-fact test. **M**: missing blocker edges. |

## Repo tooling

| File | From |
|---|---|
| `scripts/install.ps1` | **S** (junctions: symlinks need admin here), **M** `link-skills.sh` idea |
| `scripts/check-skills.ps1` + `tests/contracts.txt` | **D** prompt-contract tests, **Y** drift canary, **E** skill size guard |
| `scripts/digest-sessions.py` | written for the session analysis; reusable for the next retro |

## Left in the user folder, untouched

Matt Pocock copies that no new skill replaces (`grilling`, `grill-me`,
`grill-with-docs`, `tdd`, `triage`, `research`, `prototype`, `retro`, `wizard`,
`writing-for-agents`, `codebase-design`, `domain-modeling`, `teach`, …), the
caveman family, the PLC skills from `t_agentic_software_engineering`.
`resolving-merge-conflicts` was removed upstream (no replacement); it stays
until you decide.
