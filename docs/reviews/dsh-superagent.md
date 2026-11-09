# Review: deepseek-ai/dsh-superagent-prototype

Repo: <clone>/deepseek-ai_dsh-superagent-prototype (single commit 8c32a9d "add the dsh-superagent research prototype"). All paths below are relative to that root.

## 1. What it is

Not a general "super agent" framework and not a Claude-style loop. It is a TypeScript plugin bundle for DeepSeek Harness (DSH, a Cordis-based agent host) that turns one GitHub repository (plus optional Feishu chat) into a proactive teammate. Sources (GitHub/Feishu pollers) produce Triggers; a deterministic gate plus an LLM "main Session" (router/orchestrator) decides whether a Trigger becomes a Ticket with a Mandate; each Ticket gets its own long-lived worker Session and git worktree, and the worker reports through a six-tool interface; results go back to the original conversation (PR link, one-sentence IM). The "super agent" is mostly an authorization, attention-budget and state-machine design, with prompts as the policy layer. Maturity: self-declared research prototype (README.md:3), one commit, about 10k lines of src, large test suite (tests/*, about 60 spec files including prompt-contract tests), no benchmarks, no eval harness for agent quality (the word "eval" means admission assessment). The referenced article ("Exploring Super-agent Design: Towards a More Autonomous Agent System") is not in the repo and README.md:3-4 says some of its designs are not implemented.

License: MIT, "Copyright (c) 2026 DeepSeek Harness Team" (LICENSE:1-3). Allows use, copy, modify, merge, publish, distribute, sublicense, sell, provided the copyright and permission notice is kept in copies/substantial portions. Prompt text can be copied/adapted into Patrick's skills with that notice (a short attribution line in the skill is enough in practice). No warranty.

## 2. Inventory

Prompts (all under prompts/, one sentence per line, assembled by src/app/prompts.ts in the order given at docs/004-prompts.md:46-55):
- prompts/shared.md (7 lines): role split, shared by both roles; orchestrator must not inspect code or add requirements.
- prompts/orchestrator.md (16): main Session role: route only, never wait, never merge.
- prompts/dispatch.md (59): how to route explicit candidates (accept/attach/stop/ignore), attach-only-on-explicit-reference, 30-word note, no plan-paraphrasing, handoff of results.
- prompts/admission.md (68): proactive-candidate assessment: three-fact intent test, per-rule yes/no judgement, direction fields, scope limits, visual-feedback rejection examples.
- prompts/worker.md (10): worker role: owns technical work, reports via orchestrator_report.
- prompts/work.md (49): worker instructions: recheck scope itself, ack requests, hand back out-of-scope messages, report states, no placeholders, no polling.
- prompts/replies.md (35): reply purposes (result/attention/answer), ack rules, 100-word cap, orchestrator rewrites rather than forwards.
- prompts/handoff.md, handoff-orchestrator.md, handoff-worker.md: structured human_action question contract.
- prompts/subscriptions.md (13): thread/ticket subscription semantics.
- prompts/cli.md (17): how workers read GitHub/Feishu context recursively and honestly.
- prompts/team/scope.md (22), team/delivery.md (28), team/communication.md (97): the three operator-editable policy sections.
- skills/dsh-superagent-github/SKILL.md, skills/dsh-superagent-feishu/SKILL.md: Source read/reply skills.
- SETUP.md: an agent-run interactive setup script (one question per message, recommended default each, one confirmed plan).

Code components (src/):
- src/core/engine.ts, tickets.ts, assignments.ts, evals.ts, model.ts, replies.ts, intake.ts: pure domain core (Trigger, Thread, Eval, Decision, Mandate, Ticket, Assignment, Report), transactional, role-scoped interfaces (engine.ts:1-30).
- src/core/stage.ts: derives a ticket stage (person/answer, person/review, working/queued, idle...) from stored reports.
- src/app/tools/main.ts (14 router tools), src/app/tools/executor.ts (6 worker tools: read, ack, report, thread_unrelated, thread_follow, trigger_handback), tool.ts.
- src/app/assessment.ts: MasterAssessor, Zod AssessmentSchema forcing one yes/no entry per enabled rule plus direction fields (assessment.ts:21-34).
- src/executor/dsh.ts (673), background.ts: worker lifecycle, slots, transient retry, restart recovery, background job limits.
- src/app/sessions.ts: preset selection, WORK_TOOLS allowlist, noWait guard on the router.
- src/app/effects.ts, outbox.ts: durable "store first, do afterwards" queue with backoff.
- src/app/prompts.ts, settings.ts, versions.ts: versioned prompt/settings with base-revision conflict refusal and "Default updated" diff.
- src/policy.ts, admission.ts: gate, admission table, accept modes off/observe/auto.
- src/sources/*: GitHub/Feishu pollers; src/client/*: web panel (React); locale/*; scripts/dsh-superagent (tmux service script).
- cordis.patch.yml: DSH preset definitions (worker preset: allowlist of tools, 5s foreground-to-background shell).
- docs/000..008: philosophy, domain, authorization, execution, prompts, panel, deployment, architecture, cookbook.
- tests/cards.spec.ts, tests/model-surface.spec.ts: contract tests that assert required/forbidden phrases in prompts and size budgets per role.

## 3. Core mechanisms

**Overall loop.** Event-driven, not a ReAct loop in this repo (the inner LLM loop belongs to DSH). Flow: Source -> Trigger -> (fan-out to subscribed tickets | Eval) -> Decision -> Ticket + Assignment -> worker Session -> Report -> Channel (docs/001-domain.md:5-19, src/core/engine.ts:35-60).

**Planner/executor split = router/worker split, with the router deliberately forbidden to plan.** Router prompt: "Workers investigate and implement; never add implementation plans." (prompts/orchestrator.md:4). "Outside an assessment, the orchestrator must not inspect code, detailed logs, linked documents or technical discussion, or solve worker blockers itself" (prompts/shared.md:5). "Routing does not authorize rewriting the request: do not add requirements, implementation plans, acceptance criteria or repeated policy checklists" (shared.md:6). Routing note capped at 30 words, enforced by a Zod refinement (src/app/tools/main.ts:17-19), and the host always attaches the original trigger so a router paraphrase cannot replace the source (dispatch.md:47-50). Rationale: the router summarizing/planning is a lossy telephone game; workers re-derive requirements from the original source (work.md:23-26).

**Sub-agent spawning and context passing.** The host, not the LLM, spawns workers: one Session `worker-<ticket id>` plus a directory/git worktree per Ticket, created by a user-defined prepare command (docs/003-execution.md:25-53, src/executor/dsh.ts). Context passing = the original Trigger card (first 1,500 chars of assignment, 600 per input) plus read pointers for truncation; workers page through `orchestrator_read` resources (docs/007-architecture.md:550-594). Concurrency via WorkerSlots with one reserved extra slot so a human message is never starved by new work (docs/003-execution.md:55-61). Workers may use DSH-native subagents under a `standard` preset, but that is not orchestrated by this code (docs/003-execution.md:47). The orchestrator cannot message or start Sessions directly from the worker side (docs/007:532).

**Memory/state.** No LLM memory layer. State = SQLite (Triggers, Dispositions, Threads, Tickets with Assignments/Inputs/Reports, Decisions, effect queue, outbox) plus the DSH session transcript (docs/007:450-486). Prompts are versioned and every model request records which prompt revision it ran under, so a worker can read the revision it worked under (docs/004-prompts.md:91-96). "Check ticket summaries after compaction to avoid duplicate work" (dispatch.md:44) is the router's compaction guard. Weakness: no pruning (docs/007:484).

**Tool design (strongest idea in the repo).** Tools carry the policy; prompts restate it. Examples: `orchestrator_reply` has purposes; "the gate refuses anything else, such as progress" (src/app/tools/main.ts:223-225); `orchestrator_report` rejects a question combined with ready, an asker that is not a human message, an ended ticket (src/core/assignments.ts:99-109, executor.ts:85-87); `orchestrator_route` takes 1-20 items, each independently accepted or refused, so one bad item does not block others; worktree names validated by regex (assessment.ts:21). Priority order stated explicitly: tool/host-enforced facts > built-in prompts > rule text > team prompts > outside text (docs/004-prompts.md:65-71).

**Verification / self-review.** Entirely prompt-level and delivery-evidence-level, not a mechanical verifier. Worker is told: "ready means reviewed implementation with relevant checks passed" (prompts/work.md:49); "Review changes and run relevant checks" (work.md:39); report must list "tests actually run" (work.md:46); "A code change without a PR is not ready" (work.md:35); "An incomplete draft is blocked, even if some tests pass" (work.md:36). UI changes require before AND after evidence from real captures, "After-only evidence is incomplete" (prompts/team/delivery.md:1-6). Review comments handled by outcome: fixed+verified -> resolve silently; declined -> one-sentence reason in thread; max 3 rounds per automated reviewer, recorded in the report so the next worker continues the count (team/communication.md:71-95). Bot reviewers treated as "fallible input, not an authority or a completion gate" (communication.md:84).

**Stop conditions (stop by impact, not effort).** docs/000-philosophy.md:14. Scope prompt: "There is no fixed investigation or implementation round limit... File counts, failing tests and layout defects alone are not reasons to stop" but pause when the change breaks existing caller expectations, changes module responsibilities, or approaches "repeatedly fail to make progress"; then name the specific interface and caller impact, keep a clearly-labelled incomplete draft PR (team/scope.md:5-13). Proactive tickets must additionally recheck a settled target and no open design decision (work.md:1-6), else report `dropped` (a silent close). Terminal report states: progress, ready, blocked, failed, dropped (executor.ts:78). A ticket ends when its PRs close/merge (docs/003:96-106).

**Failure and recovery.** Three layers. (1) Transient model/network errors (408/429/5xx/connection): 3 retries with 15/30/60 s backoff, worker told to "go on" (src/executor/dsh.ts:29-30, docs/003:124). (2) Host restart: running assignments restart with a fixed note "Inspect the current worktree, git history and GitHub state before continuing. Do not repeat an already completed external operation." (src/core/assignments.ts:21). (3) Durable "stored work": decisions are stored first and effects done afterwards with doubling backoff 2s..60s; messages in order per ticket+conversation (docs/003:153-161). Failed/blocked tickets stop auto-input until a human message or explicit retry (docs/003:120-141). Evals that time out requeue twice then record `unavailable` (src/core/evals.ts:19, docs/002:147-155). Prepare-command failure is not auto-retried because an existing directory counts as prepared (dsh.ts:41, 256).

**Admission/assessment (second strongest).** Proactive work is accepted only if three independent facts hold: targets this project, participants express intent for a specific change, direction settled for a small local edit (prompts/admission.md:6). Output forced into a schema: `rule_assessments` with exactly one entry per enabled rule including negatives, plus `implementation_requested`, `target_basis`, `requires_design_decision`, `evidence` (admission.md:17-28, assessment.ts:21-34). "Examples only show format. An example sentence is not a fact the agent may claim." (docs/004:87, communication.md:60). Observe mode records "would accept" without acting (docs/002:91-101) to calibrate before enabling auto. Good/bad calibration examples are embedded (admission.md:9-10, 37).

**Attention economy.** Every outward message must be justified: "Before sending, identify what the human can now review, use, decide or unblock; if nothing, send nothing." (team/communication.md:18). "Would deleting this prevent the human from understanding the result or taking the required action? If not, delete it." (communication.md:51-52). Orchestrator must write a new notification, not forward or compress the worker report (replies.md:31-32). One structured `human_action` question at a time, routed to where the human wrote (handoff-worker.md:1-6). 100-word hard cap enforced by transport (replies.md:27-30).

**Ownership of follow-ups.** A person's message on a ticket's own thread goes straight to its worker; worker must act+ack, or hand back once with a reason, "never drop a request silently" (work.md:9). Only after all owners hand back does it become a new candidate. Only the main Session may stop a ticket, and only on a person's stop (dispatch.md:31-33).

## 4. Strong vs weak

Strong, ranked:
1. Thin orchestrator that cannot add requirements; originals pass through untouched; capped routing note. Directly counters the "orchestrator rewrites the ticket and corrupts the bar" failure. (shared.md:5-7, dispatch.md:37-42, main.ts:17-19)
2. Policy lives in tool schemas/gates, with prompts as the soft layer; explicit priority ladder; contract tests that grep the shipped prompts for required/forbidden phrases (tests/cards.spec.ts:13-40, tests/model-surface.spec.ts). Makes prompts testable.
3. Forced explicit negative judgement per rule + "observe" shadow mode before "auto". Calibrates an LLM gate without risk.
4. Honest-delivery vocabulary: five report states, draft-is-blocked, no placeholder PR numbers, before/after evidence, "tests actually run", "do not claim success for an impossible ticket" (work.md:33,47).
5. Stop-by-impact scope rule with named pause conditions and a preserved-draft behavior (team/scope.md).
6. Single owner per message + handback-once + no silent drops; recovery note "check state before repeating outside actions".
7. Attention-budget writing rules for outward messages (communication.md).
8. Durable store-then-effect queue, idempotency keys (accept idempotent by trigger id, dispatch.md:46), restart recovery.

Weak / gimmick / won't survive real work:
- The "super agent" label oversells: no planner, no multi-step plan objects, no verifier agent, no learning memory, no sub-agent fan-out designed by the LLM. Verification is "the worker says it reviewed". No independent reviewer exists; only third-party bots/humans on the PR (work.md:39 is the only self-check).
- Heavy infrastructure (SQLite, Cordis plugins, tmux service, web panel, Feishu) is irrelevant to a desktop CLI user and is not portable.
- Prompt style is dense, rule-pile prose with many one-off patches (visual-CSS examples repeat in admission.md, work.md, scope.md, handoff-worker.md, tests). Clearly accreted from incidents; hard to reuse wholesale.
- "No fixed round limit" for the worker (scope.md:5) risks long unattended loops; the only budget is the 3-round automated-reviewer cap and the 30 min background limit.
- Trust model unresolved (docs/007:616 open question); workers run without approval as the operator's OS user; blocked commands are "defaults, not a security boundary" (docs/003:80).
- Router "never read code" is a prompt rule, not a tool restriction (docs/007:507).
- No eval of outcome quality; no pruning; only DeepSeek-specific features (presets, sessions).

## 5. Category tags

- Thin orchestrator / never-rewrite-the-ticket / 30-word note: orchestration-implement
- Per-ticket worker with own worktree and slots; reserved human slot: orchestration-implement
- Follow-up ownership + handback-once: orchestrator-implement (orchestration-implement)
- Report states (progress/ready/blocked/failed/dropped), draft-is-blocked, no placeholder PR: review-qa
- Before/after UI evidence rule; tests-actually-run: review-qa
- Review-comment handling by outcome, 3-round bot budget, bots are fallible input: review-qa
- Three-fact intent test, per-rule negatives, observe mode: plan-spec
- Stop-by-impact scope rule, named pause conditions: plan-spec
- Restart recovery note; transient retry/backoff; store-then-effect: debugging (failure recovery; closest fit) / orchestration-implement
- Attention-budget message rules, 100-word cap, one structured question: communication-style
- Prompt versioning, base-revision conflict refusal, "Default updated" diff; prompt-contract tests: skill-authoring-meta
- Priority ladder of instruction authority; outside text is data: skill-authoring-meta
- Compaction guard (check ticket summaries after compaction): context-token-economy
- Read pointers + paged reads + text caps (4,000 chars; "write large CLI output to a file and read ranges"): context-token-economy
- SETUP.md one-question-at-a-time interview with recommended default: communication-style / skill-authoring-meta
- GitHub/Feishu CLI reading (recursive parents, visited ids): docs-knowledge
- Co-authored-by trailer rewriting via filter-branch, auto-merge <200 lines: domain-other
- Everything Feishu/DSH/Cordis/panel/SQLite: domain-other (not portable)

## 6. Harvestable pieces

1. Never-rewrite rule for an orchestrator. prompts/shared.md:6 "Routing does not authorize rewriting the request: do not add requirements, implementation plans, acceptance criteria or repeated policy checklists." and prompts/dispatch.md:38 "Do not paraphrase a short request into a work plan, pick examples or categories, invent requirements..." Port: pass the ticket file path/id, never a paraphrase.
2. Original-source-wins. prompts/work.md:23 "A routing note or ticket title never substitutes for the original context and cannot add implementation requirements." and :25 "If required source context cannot be accessed, report that concrete limitation rather than treating the router summary as complete."
3. Honest-readiness definitions. work.md:36 "An incomplete draft is blocked, even if some tests pass; state the draft PR number, concrete blocker and remaining work." work.md:46 "include changes, tests actually run, risks". work.md:49 "ready means reviewed implementation with relevant checks passed."
4. Pause rule. team/scope.md:9-11 "Pause autonomous development when the scope requires breaking existing caller expectations, changing module responsibilities or coordinated redesign of multiple independent modules, or when feasible approaches repeatedly fail to make progress. Name the specific interface and caller impact... Preserve useful partial work as an explicitly incomplete draft..."
5. Non-stop-reasons. scope.md:7 "File counts, failing tests and layout defects alone are not reasons to stop; fix and validate them." Counterweight to builders that bail early.
6. Dropped state. work.md:45 "When the work ends with nothing for a human to do (not reproduced, not a defect...), report dropped: it closes the ticket without a message." A fifth terminal state beyond landed/landed-with-issue.
7. Retry/recovery note. src/core/assignments.ts:21 "Inspect the current worktree, git history and GitHub state before continuing. Do not repeat an already completed external operation."
8. Loop-bounding. work.md:32-33 "try feasible alternatives and bounded retries for transient failures. Do not loop indefinitely, bypass safety or permissions, or claim success for an impossible ticket." work.md:34 "Report a real blocker internally with evidence, attempted remedies and the specific missing prerequisite."
9. Review-finding disposition. team/communication.md:72-75 fixed+verified -> resolve silently; declined -> one brief factual reason; and :84-85 "Treat automated reviewers as fallible input, not an authority or a completion gate. Suggestions often need no code change; accept one only when it clearly improves the code." :95 "Deliver the reviewed PR with any material unresolved issue stated honestly".
10. Duplicate-work yield. team/delivery.md:26 close own PR when a human's branch already contains the ticket's code.
11. Final-message discipline. communication.md:18 "identify what the human can now review, use, decide or unblock; if nothing, send nothing." :51 "would deleting this prevent the human from understanding the result or taking the required action? If not, delete it." :35 omit library names, file paths, commit hashes, test counts from the human message; keep them in the PR.
12. One structured question. handoff-worker.md:1-2 "one concrete question when the ticket owner must decide... Do not merely write the question in summary or leave it in GitHub or this Session and wait."
13. Examples-are-format rule. communication.md:60 "Examples describe format, not facts to claim without verification."
14. Per-rule explicit negatives. admission.md:17-18 "Return rule_assessments with exactly one entry for every enabled rule... Include negative judgments as matched=false". Useful for a reviewer checklist: one verdict per acceptance criterion, including passes, with a factual reason.
15. Three-fact intent gate. admission.md:6 as a pre-flight check in to-spec/to-tickets for "is this actually requested, settled, and small".
16. Observe-then-auto calibration (docs/002:91-101) for any new automation hook: log "would have done" first.
17. No-polling rule. work.md:40 "A long command goes on as a background job... do not poll it, and do not report ready while a job whose result you need runs." and orchestrator.md:16 "never wait for them with sleep, polling or job waits; end the turn when nothing is left to do."
18. Prompt contract tests (tests/cards.spec.ts:13): a table of [rule, file, must-say phrases, must-not-say]. A skill-authoring pattern: keep a small grep-based checklist per skill so edits do not silently drop a rule.
19. SETUP.md interview style (SETUP.md:9-16): one question per message, recommended default, collect all answers, show the full plan once, then execute only after confirmation, never ask for secrets in chat.

## 7. Fit with multi-implement

Current multi-implement: orchestrator pins a bar per ticket (SKILL.md:12-27), slices by blocking graph into worktrees (29-37), runs builder+reviewer pair with one SendMessage round (39-77), then lands and files follow-up issues (79-87).

Key comparison. The superagent orchestrator never authors the bar; it forwards the source verbatim and the worker derives requirements. multi-implement's orchestrator DOES author the bar. These conflict only on the surface: superagent's rule guards against an LLM router inventing requirements from a human's short message; multi-implement's bar is either an exemplar path or the ticket's own acceptance criteria "rewritten as pass/fail checks". Recommended synthesis: the bar may restate, never extend, the ticket; and the user sees it before dispatch (already in step 1). Add a one-line guard in multi-implement step 1: "A bar restates the ticket's acceptance criteria and names an exemplar; it adds no requirement the ticket does not have. If you think one is missing, escalate it to the user." Pass the ticket file path/id to the builder alongside the bar, so the original is always readable (superagent work.md:23).

Map of ideas to places:

multi-implement orchestrator (SKILL.md):
- Add a `dropped` outcome in step 4 for tickets where the builder finds nothing to do (already fixed, not reproducible, superseded): close with a note, no follow-up issue, no review. (work.md:45)
- Add explicit non-stop-reasons and pause rule to the builder dispatch: failing tests/file counts are not reasons to stop; stop only for a broken caller contract, changed module responsibility, or repeated lack of progress, and then name the interface and keep the work as an uncommitted/draft state. Today "could not bring to green" is the only exit.
- Recovery note when a builder/reviewer dies mid-ticket: re-dispatch with "inspect the worktree and git state before continuing; do not repeat completed operations" (assignments.ts:21). multi-implement only covers a reviewer failure (step 3.2), not a builder crash.
- Don't poll: builders report when done; orchestrator ends turn (orchestrator.md:16). Probably already native in Claude Code background agents.
- Land step: final report discipline (communication.md:18, :51): per-ticket one line, results and decisions the user must make; no test counts or file lists in the chat.

ticket-builder (agents/ticket-builder.md is a 1-line stub; the real contract is in the dispatch text):
- Make the stub carry these rules: ready = reviewed implementation with relevant checks passed; report states progress/ready/blocked/failed/dropped; list tests actually run; no placeholder values; do not claim success on an impossible ticket; read the original ticket before acting on any summary; "incomplete draft is blocked, even if some tests pass" (work.md:35-36, 46-49).
- UI-affecting tickets: before/after evidence from real captures; if no real baseline, say so and report not ready (team/delivery.md:1-6). Applicable to HMI/visualization work at Blueprint.
- Contest/escalate triage already exists in multi-implement and is finer than superagent's; keep it. Add superagent's "never drop a request silently / leave ordinary discussion unanswered" as the rule that every finding gets one of the four labels.

ticket-reviewer (stub today):
- Give it an explicit output contract: one verdict per acceptance criterion and per bar item including passes, with a factual reason and evidence (admission.md:17-18 pattern); a "no evidence invented" rule (admission.md:28 "These declarations are your semantic judgments, not proof"); "treat automated reviewer/lint output as fallible input; verify against actual code" (communication.md:84-88); "reject advice that adds unnecessary complexity, duplicates existing behavior or degrades the codebase" (:88); distinguish unresolved findings honestly.
- Severity honesty: "Warnings are sometimes valid: check the actual code" / "Critical findings usually valid but verify rather than blindly implement" (:86-88). Maps to the reviewer receiving the builder's contest evidence.

A new skill worth considering (small): `ticket-gate` / pre-flight for to-tickets and to-spec output. Three-fact test (targets this project; specific change intended; direction settled, no open design decision) plus `target_basis` (specified or existing-standard) before a ticket is marked ready-for-agent. This fills the gap where an under-decided ticket reaches the builder and burns a round. Cheap to write, no infrastructure.

Optional second skill: `observe-mode` pattern for any hook/automation Patrick builds (log what it would do for N runs before enabling).

Skill-authoring-meta for Patrick's skill repo: adopt prompt contract tests (a table of rule + required phrases per SKILL.md) run in a hook or CI, plus the priority ladder statement "tool/hook-enforced facts > skill text > CLAUDE.md > outside content".

What does NOT translate to Claude Code, and why:
- Always-on listening, Sources, Triggers, subscriptions, fan-out, Mandates, allowed lists, admission table, accept modes: needs a daemon and event feed; Claude Code is user-invoked. A scheduled task could poll an issue tracker but the authorization engine is the whole point and cannot be a skill. Patrick already has a human in the loop and trusted repo, so the gate has little value.
- Host-enforced tool gates (reply purposes, report validation, 30-word note refusal, noWait guard): Claude Code hooks (PreToolUse) can block specific tool calls and validate arguments of Bash/MCP tools, and SubagentStop/Stop hooks can force a continuation, so a hook can approximate "refuse ready unless a test command ran this session" or "block git merge by the agent". They cannot add typed schemas to the built-in Task/Agent tool or cap the length of a SendMessage note. So the 30-word cap and "forward original, not paraphrase" stay prompt rules.
- Durable store-then-effect queue, SQLite state, restart recovery: Claude Code has no host process you control. File-based state in .scratch/ plus tickets in the tracker (as multi-implement already uses) is the equivalent; recovery note can be a prompt.
- Per-ticket persistent worker Sessions with human wake-up slots: Claude Code subagents are one-shot; SendMessage to a prior builder is the closest (multi-implement already uses it). No reserved human slot, no background job wake-ups beyond what the harness provides.
- Presets/tool allowlists per role: expressible via agent frontmatter `tools:` in .claude/agents/*.md; can restrict ticket-reviewer to read-only (Read, Grep, Glob, Bash for tests) which multi-implement does not do today (both agents have all tools). Worth doing; it is the Claude-native version of "router cannot read code" (which superagent only enforces as a prompt rule).
- Web panel, Feishu/IM, attention UI: not applicable.
- Prompt versioning with base-revision conflict refusal: git covers it.
- Co-authored-by rewriting with filter-branch, auto-merge under 200 lines: team-specific, and rewriting commit history is risky; skip.

Bottom line for Patrick: superagent is a different animal (a server-side autonomy/authorization system) and its architecture confirms multi-implement's shape rather than replacing it: thin orchestrator, fresh-context workers, one owner per ticket, bounded retries, honest terminal states. Take the prompt-level discipline (never-rewrite, dropped state, pause rule, report vocabulary, per-criterion verdicts, fallible-reviewer stance, outbound message discipline) and the pre-flight three-fact gate for tickets. Do not take the infrastructure.
