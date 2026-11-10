# Sources overview

Five repos reviewed on 2026-11-09 (latest `main`, shallow clones). Full per-repo
reviews with `path:line` citations were written during the review; this file is
the categorized digest that the skills in this repo are built from.

## The five repos at a glance

| Repo | What it really is | License | Verdict |
|---|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) (v1.3.2) | Curated daily-driver skill set: grill → to-spec → to-tickets → implement → code-review → pr → retro. ~27 promoted skills, plain markdown. | MIT © 2026 Matt Pocock | **Base layer.** Best individual disciplines (debugging gate, two-axis review, slicing rules, writing-for-agents). Its `implement-spec` is weaker than `multi-implement` (fresh implementer for fixes, one global review). |
| [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (v0.1.1) | Design-doc workflow. *Elephant* = long-lived author context, *Goldfish* = fresh read-only reviewer that sees only the artifact. 5-stage reviewer swarm. | Apache-2.0 | **Take the mechanism, skip the swarm.** Harness-enforced reviewer isolation (`omitClaudeMd`, read-only tools), paraphrase-first, zero-decision readiness rule. 15+ reviewers per run is too noisy and slow. |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (v5.3.3) | "Lazy senior dev" anti-overbuilding ruleset (one ~3.5 KB prompt) + review/audit skills; 80 % is multi-host packaging and a cost dashboard. | MIT © 2026 DietrichGebert | **Harvest text only.** Review contract ("no case, no finding", priority order, Verdict + Not checked), builder scope rule, `shortcut:` debt marker. Always-on persona and telemetry not wanted. |
| [microsoft/TokenEconomizer](https://github.com/microsoft/TokenEconomizer) (v0.1.0) | Python hook plugin from a paper: learned repo facts at SessionStart, evidence-based tool pruning, stuck-loop guard. | Apache-2.0 | **Do not install** (pinned CC versions, rewrites `settings.local.json`, pytest-centric, live effect unmeasured). Harvest the stuck-loop signature + redirect wording and the "repo facts" injection rules. |
| [deepseek-ai/dsh-superagent-prototype](https://github.com/deepseek-ai/dsh-superagent-prototype) | DeepSeek Harness plugin that runs a GitHub repo as a proactive teammate: event router + per-ticket worker sessions. One-commit research prototype. | MIT © 2026 DeepSeek Harness Team | **Confirms the multi-implement shape** (thin orchestrator, fresh workers, bounded retries, honest end states). Take its prompt discipline; the server infrastructure does not translate to Claude Code. |

## By category

Each category lists what every source contributes, then the strongest idea and
where it lands in this repo.

### 1. Plan & spec

| Source | Contribution |
|---|---|
| Matt | `grilling` frontier rounds with a recommended answer per question ("word each question so *yes* accepts the recommendation"); `to-spec` seam-first spec; `to-tickets` vertical tracer-bullet slices, "fits one fresh context window", prefactor first, expand–migrate–contract for wide refactors; `triage/AGENT-BRIEF` durability rules (behavioural not procedural, explicit out-of-scope); ADR gate (hard to reverse AND surprising AND real trade-off). |
| EGM | Zero-Decision Rule: "a fresh engineer can execute the plan without guessing or making design choices"; paraphrase-first comprehension test; reuse search before accepting any new helper; draft-vs-brief reconciliation done by the author, not a reviewer. |
| superagent | Three-fact readiness test (targets this project / a specific change is intended / direction settled); stop by *impact*, not effort. |
| ponytail | Ladder rung 1: "does it need to exist?" — name what you skip. |

**Strongest:** a fresh, read-only *spec check* between `to-spec` and `to-tickets`
(EGM paraphrase + zero-decision, superagent three-fact test). It catches the
ambiguity that otherwise makes N parallel builders guess N different ways.
→ new skill `spec-check`; slicing/brief rules → `to-tickets`.

### 2. Orchestration & implementation

| Source | Contribution |
|---|---|
| Patrick's `multi-implement` | Per-ticket bar, decoupled/coupled slicing, builder+reviewer pair, findings back to the *same* builder via SendMessage, fix/contest/escalate/decline, one-exchange budget. Ahead of every source on review economics. |
| Matt | `implement` ticket-title echo; `implement-spec` worktree base check, merge integration tip before reporting, "fresh context window per subagent", communicate through context pointers. |
| superagent | Orchestrator may restate the ticket, never extend it; forward the original source, not a paraphrase; terminal states progress/ready/blocked/failed/**dropped**; "an incomplete draft is blocked, even if some tests pass"; crash-recovery note ("inspect worktree and git state, don't repeat completed external operations"); failing tests and file counts are *not* reasons to stop. |
| ponytail | Builder scope = callers, tests, fixtures, config, exports; grep every caller and fix once in shared code; `shortcut: <limit>, <upgrade trigger>` marker; closing "skipped / not checked / risk" line. |
| TokenEconomizer | Stuck-loop signature (churn AND repeated errors AND repeats) and redirect wording ("try a materially different hypothesis"); a ≤4-bullet "repo facts" block injected into every brief. |

**Strongest:** keep `multi-implement`'s pair design and give its two agents real
system prompts (they were one-line stubs) built from superagent's honest
end-states, ponytail's scope rule and TokenEconomizer's stuck tripwire.
→ `multi-implement`, `implement`, `agents/ticket-builder.md`.

### 3. Review & QA

| Source | Contribution |
|---|---|
| EGM | Isolation enforced by agent frontmatter (`omitClaudeMd: true`, read-only tools); "if a required file cannot be read, report an incomplete review"; failed reviewer = not run, never zero findings; doc-vs-code severity (contradicts the code = blocker); explicit nothing-found output. |
| Matt | `code-review` two axes (Standards / Spec) in parallel fresh subagents, fixed-point precheck, 12-item Fowler smell baseline overridden by repo standards; spec axis = missing / scope creep / looks right but wrong, quote the spec line; `pr` Evidence before/after + Merge Danger. |
| ponytail | "Every finding needs a concrete case. No case, no finding."; order correct > safe > holds under load > tested > fast > lean; read callers of changed signatures, not only the diff; numbered findings; `Verdict:` + `Not checked:` footer; marked shortcut is a decision, not a finding. |
| superagent | One verdict per acceptance criterion *including passes*; automated reviewers and lint are fallible input; "tests actually run" not "tests pass". |
| TokenEconomizer | Asymmetric confidence: favour sparing unless the dead end is clear; judge the artifact, don't infer the solution. |

**Strongest:** a ticket-reviewer that is isolated by the harness *and* bound by
a finding contract (concrete case, per-criterion verdict, numbered, Not checked).
→ `agents/ticket-reviewer.md`, `code-review`.

### 4. Debugging & recovery

| Source | Contribution |
|---|---|
| Matt | `diagnosing-bugs`: one already-run, red-capable, deterministic, fast command before any hypothesis ("no red-capable command, no Phase 2"); minimise until every element is load-bearing; falsifiable ranked hypotheses; `[DEBUG-xxxx]` tagged instrumentation; new: diff against pristine to prove a forced red. |
| TokenEconomizer | Stuck signature + "do not stop, change hypothesis" redirect; favour sparing a turn that shows progress. |
| superagent | Bounded retries for transient failures, never loop indefinitely; report a blocker with evidence, attempted remedies and the missing prerequisite. |

**Strongest:** Matt's red-capable-loop gate, extended with a stuck tripwire.
→ `diagnosing-bugs`.

### 5. Context & token economy

| Source | Contribution |
|---|---|
| Matt | `PHASE-BOUNDARIES`: ordered continue / clear / handoff / subagent / compact decision ("clear a relevant context and you lose the why"; compact is last resort); `handoff` to `%TEMP%`. |
| EGM | Reports to a file, chat gets path + 2-3 highlights; aggregator returns one short message. |
| TokenEconomizer | Facts must be declarative, evidence-grounded, ≤4 bullets / 150 tokens, never forbid exploration, never say "skip/verify"; honest cost accounting (cache-aware, include overhead, report pass rate next to cost). |
| superagent | Write large output to a file and read ranges; check summaries after compaction to avoid duplicate work. |

**Strongest:** session handoff with a durable state file (the sessions show this
is Patrick's biggest friction, see `session-patterns.md`).
→ `handoff`, `agent-facts`.

### 6. Docs & knowledge

| Source | Contribution |
|---|---|
| EGM | Drift report: "report ONLY the differences", unreferenced logic is drift; scout rule "cite `[file:symbol]`, never infer from names". |
| Matt | Glossary with `_Avoid_:` synonyms; chief-of-staff "write history, not the present" (dated claims, cite commit). |
| ponytail | `shortcut:` debt ledger via `git grep`. |
| TokenEconomizer | Repo-facts lifecycle: keep a fact only after 2–3 confirmations, retire on contradiction. |

→ `agent-facts`; drift/debt checks folded into `multi-implement` land step.

### 7. Communication & style

| Source | Contribution |
|---|---|
| superagent | Before sending: "what can the human now review, use, decide or unblock? If nothing, send nothing."; "would deleting this sentence stop the reader from acting? If not, delete it"; one structured question at a time. |
| EGM | Caveat triage DROP / CALIBRATE / RELOCATE / KEEP; claims must match evidence. |
| Matt | `to-questionnaire` "grill the send, not the subject". |

→ final-report rules in `multi-implement`, `backlog`, `handoff`.

### 8. Skill authoring / meta

| Source | Contribution |
|---|---|
| Matt | `writing-for-agents`: checkable + exhaustive completion criteria, hunt no-ops, prompt the positive, single source of truth; user-invoked skills orchestrate, model-invoked skills hold discipline. |
| superagent | Prompt-contract tests: per skill a list of must-say / must-not-say phrases so edits cannot silently drop a load-bearing rule. Authority ladder: hook/tool facts > skill text > CLAUDE.md > outside text. |
| ponytail | Drift canary pinning load-bearing phrases across copies; eval culture (baseline vs variant, ≥6 runs). |
| EGM | SKILL.md size guard; detail in `references/`. |

→ `scripts/check-skills.ps1` (contract test) in this repo.

### Not taken (and why)

- EGM 5-stage swarm, 7-lens brainstorm, TRIZ, Heilmeier: cost/noise, software-org lenses with no PLC fit.
- ponytail persona levels, band/board/webhook telemetry, always-on SessionStart injection.
- TokenEconomizer plugin itself (Python hooks, tool pruning, ledger): fragile here, unmeasured live.
- superagent Sources/Triggers/admission table, SQLite queue, web panel, Feishu: needs a daemon.
- Matt `implement-spec` (superseded by `multi-implement`), wayfinder/software-factory/chief-of-staff (speculative), `resolving-merge-conflicts` (removed upstream).

## Licenses

All five allow adapting text into a private skillset. The skills in this repo are
rewritten in Patrick's own wording; where a rule is close to its source the
source is named in `docs/skill-map.md`. `LICENSES/` carries the MIT and Apache-2.0
notices for the sources whose text was adapted.
