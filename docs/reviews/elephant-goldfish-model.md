# Review: google/elephant-goldfish-model (EGM)

Repo root (all paths below relative to it): <clone>/google_elephant-goldfish-model

## 1. What it is

EGM is a spec-driven-development plugin (Claude Code, Codex, Antigravity, Cursor, Copilot, opencode) from Dave Rensin's essay. The idea: **Elephant** = the long-lived main-context agent that holds project memory, interviews the user, and drafts the spec. **Goldfish** = a fresh, zero-history, read-only subagent that reviews the *artifact only* (doc + files it links), so it cannot share the author's blind spots. **Human** = decides trade-offs and approves. It is explicitly doc-centric (brief -> design doc -> staged review -> human PR review -> implement); it does not implement code (`resources/execution_instructions.md:3-12`). Why it works: the author-model validates its own assumptions (docs/designs/architecture.md "The Problem", docs/designs/review.md "The Problem"); a context-free reader with a narrow lens and a rubric finds the unstated assumptions. Isolation is enforced mechanically on Claude via `omitClaudeMd: true` + `tools: [Read, Grep, Glob]` (`.claude-plugin/agents/comprehension.md`, docs/claude.md:129-166).

Maturity: v0.1.1 (`.claude-plugin/plugin.json:4`), Google-owned but "not an officially supported Google product" (README:137), single squashed commit in this clone. Heavy engineering around it: ~18 unit-test modules (frontmatter, links, packaging, trace validators), opt-in live harness probes with recorded native traces (TESTING.md harness table), per-skill `test_scenarios.yaml` regex evals (weak: required/forbidden string patterns, e.g. skills/egm-review/test_scenarios.yaml:19-53). Honest FAQ: admits velocity cost, no productivity proof (docs/faq.md). No hooks, no slash-command files, no scripts that matter for behavior (scripts/ = packaging only). Lots of multi-harness adapter noise (cursor/copilot/codex/opencode dirs, `distributions/claude/` duplicate) that is irrelevant to Patrick.

License: **Apache License 2.0**, verbatim standard text (LICENSE, 11,560 bytes; appendix boilerplate left with `[yyyy] [name of copyright owner]` placeholders, LICENSE:190-205; no NOTICE file). Per-file headers `Copyright 2026 Google LLC / SPDX-License-Identifier: Apache-2.0` (docs/claude.md:1-4); skill/agent frontmatter `license: Apache-2.0`. Allows: copy, modify, redistribute, commercial/private use. Obligations if you copy/adapt text into your own skills and redistribute: keep the Apache license text and copyright notices with copies, mark files you changed, no trademark use. For a *private* personal skillset it is effectively unrestricted; if you publish, add an attribution line + license copy. Your own rewording carries no obligation.

## 2. Inventory

### Skills (all `disable-model-invocation: true`, i.e. slash-only)
| Name | Path | Purpose |
|---|---|---|
| egm-brainstorm | skills/egm-brainstorm/SKILL.md (271 lines) | Interview user open-endedly, gate, then 7-lens parallel goldfish swarm -> `concepts_brief.md` |
| egm-draft | skills/egm-draft/SKILL.md (321) + references/design_doc.md | Section-by-section design doc with per-section approval gate; reconcile vs brief at end |
| egm-review | skills/egm-review/SKILL.md (426) | 5-stage sequential review pipeline with presets + checkpoint gates |
| egm-review-loop | skills/egm-review-loop/SKILL.md (199) | Configurable reviewer panel loop: dispatch -> consolidate -> resolve -> convergence rules |
| egm-resolve | skills/egm-resolve/SKILL.md (187) | Elephant triages findings: CONTEST / ESCALATE / PROPOSE FIX / DECLINE |
| egm-drift-report | skills/egm-drift-report/SKILL.md (67) | Compare design docs/READMEs to code; report only differences |
| egm-bootstrap | skills/egm-bootstrap/SKILL.md (429) + references/{templates.md,worker-return.schema.json} | Bottom-up README "contract" generation per directory, swarm of workers |
| (per skill) TEST.md, test_scenarios.yaml, agents/openai.yaml | skills/*/ | regex evals / Codex metadata |

### Agents (canonical persona in `agents/*.md`; Claude adapters in `.claude-plugin/agents/*.md` that just say "read ${CLAUDE_PLUGIN_ROOT}/agents/X.md")
| Agent | Path | Purpose |
|---|---|---|
| egm-comprehension | agents/comprehension.md | Naive reader; paraphrase-first self-containment test |
| egm-design | agents/design_critic.md | Hostile design critic (assumptions, SPOF, risk) vs feature-spec-standard |
| egm-zoom-out | agents/zoom_out.md | Skeptical architect: YAGNI, reuse via code search, altitude |
| egm-structural | agents/structural.md | Heading/template conformance |
| egm-style | agents/style.md | Copy editor + defensive-caveat triage (DROP/CALIBRATE/RELOCATE/KEEP) |
| egm-codebase-details | agents/codebase_details.md | Doc-vs-code accuracy auditor |
| egm-implementation-readiness | agents/implementation_readiness.md | "Could I code this with zero decisions?" |
| egm-inventive-catalyst | agents/inventive_catalyst.md | TRIZ contradiction finder + 10-pattern catalog |
| egm-synthesizer | agents/synthesizer.md | Spawns swarm, dedups, severity-groups, writes report, returns one short message |
| egm-bootstrap-orchestrator | agents/bootstrap_orchestrator.md | Partition tree, spawn bootstrap workers |

### Resources (rubrics)
resources/document_standards/{feature-spec,implementation-readiness,zoom-out,re-implementation,heilmeier}-standard.md; resources/execution_instructions.md.

### Commands / hooks / scripts
None as files. Commands = the skills. No hooks shipped (docs/claude.md:57-60 "EGM does not install a permission-approval hook"). scripts/pack_plugin.py, prepare_release.py = packaging. tests/, .github/workflows/ = CI. adapters/, .cursor-plugin, .codex-plugin, com.github.copilot, distributions/ = harness ports (ignore).

## 3. Core mechanisms

1. **Context isolation by construction.** Reviewer = fresh Agent per review, never forked/resumed, given only task + target + persona/standard paths + explicit "GoldfishContext" reading list. docs/claude.md:129-134 ("Do not fork the conversation or resume a previous reviewer"); skills/egm-review/SKILL.md:19-28 ("a review in the same context is not a Goldfish review" - refuse rather than degrade). Adapter frontmatter `omitClaudeMd: true`, read-only tools (`.claude-plugin/agents/comprehension.md:5-8`). Isolation is probe-tested (TESTING.md:78-92).
2. **Persona-file read-first adapter pattern.** Thin Claude adapter points at harness-agnostic canonical persona; adapter owns tool restrictions, persona owns behavior (docs/claude.md:116-127). Reviewer "must read target and every standard or report an incomplete review instead of a verdict" (`.claude-plugin/agents/comprehension.md:15-17`).
3. **Standards as pass/fail rubrics with one "Core Principle" = fresh-engineer test.** e.g. "passes if a competent engineer (or fresh AI session) ... can execute the plan ... without guessing" + "Zero-Decision Rule" (resources/document_standards/implementation-readiness-standard.md:3-17); Alternatives Rule in feature-spec-standard.md.
4. **Paraphrase-first comprehension test.** Reviewer must restate what the doc proposes before critiquing; failure to paraphrase = Blocker; wrong paraphrase is itself a finding; the synthesizer is bypassed so the paraphrase survives (agents/comprehension.md:37,57; skills/egm-review/SKILL.md:351-359).
5. **Sequential staged pipeline, parallel within stage.** Zoom-out -> comprehension -> critic -> intermediate zoom-out -> readiness; "uninterrupted mode skips human checkpoints, not stage dependencies" (docs/claude.md:44-47; egm-review/SKILL.md:282-303). Cheap high-altitude checks first so expensive detail review is not spent on a doc that gets restructured. Step 8 re-runs zoom-out on additions only, "avoiding re-flagging decisions accepted in Step 5" (docs/designs/review.md Stage 8).
6. **Failed-reviewer rule.** "A reviewer that times out, fails, or returns no report did not review. Retry once. If it fails again, status `not run` ... Never count it as a reviewer with zero findings." (agents/synthesizer.md:31,41; egm-review-loop/SKILL.md:327-331). Patrick's multi-implement already has the same rule (SKILL.md:50-51).
7. **CONTEST / ESCALATE / PROPOSE FIX / DECLINE triage, evidence-bound.** egm-resolve/SKILL.md:56-82: contest only with evidence the reviewer could read; "You wrote the document under review. A wish to contest is not evidence"; do not contest comprehension gaps; do not add context only to satisfy a zero-context reviewer -> ESCALATE; do not change severity, contest it. Essentially identical to multi-implement step 3 (shared lineage).
8. **Convergence rules for repeated fresh reviewers.** Settled findings persist across rounds (not re-opened); a fixed finding that re-appears re-opens; clean round = no unsettled Blocker/Major, a not-run reviewer makes the round unclean; converged = 2 consecutive clean rounds; cap 5; churn detector ("new finding at scope of an applied fix, reverting that fix would resolve it") -> ask user (egm-review-loop/SKILL.md:344-368). Plus 1-re-audit cap per stage (egm-review/SKILL.md:271-275).
9. **Artifact-first, no chat dumps.** Reports/drafts go to files, chat gets path + 2-3 highlights (egm-review/SKILL.md:32-37; egm-draft Step 2.5). Synthesizer returns a "single, concise completion message" to protect parent context (agents/synthesizer.md:14). Hierarchy: parent -> synthesizer -> N reviewers.
10. **Human gates: one question per turn, sole tool call, no "(Recommended)", no ranking.** egm-review/SKILL.md:65-70; egm-draft rule 13 "Author Decides Architecture": present <=3 options with mechanism + failure conditions, do not rank, do not pick even if asked.
11. **Anti-sycophancy block** (13 numbered rules, copy-pasted across brainstorm/draft/review): critique first, banned flattery adjectives, banned apologies, generate strongest counter-argument, "earn your agreement" (egm-review/SKILL.md:44-64).
12. **Reconcile draft vs predecessor from the Elephant, not a Goldfish**, because only the Elephant has both (egm-draft/SKILL.md Step 6.1): list contradictions brief-vs-draft, ask user, do not auto-conform since the draft may know more from code.
13. **Doc-vs-code grounding auditors.** codebase_details: "Contradicts the Code = Blocker", "Non-Existent References: check every one", plus "Proposed files are not findings" carve-out (agents/codebase_details.md:47-50). zoom_out MUST code-search before accepting any new utility (agents/zoom_out.md:45).
14. **Style persona caveat triage** DROP/CALIBRATE/RELOCATE/KEEP; "require every claim about existing or tested behavior to match its evidence" (agents/style.md:38,48).
15. **Bootstrap**: BFS (never `find`/`ls -R`), safety gate >15 dirs, adaptive depth partition, scout returns JSON with `[file:symbol]` citations and "never infer from names", ~1,500-line chunking, post-order traversal, mandatory final read-every-file verification, optional drift report (skills/egm-bootstrap/SKILL.md:98-200, 204-270, 346-380).
16. **Inventive Catalyst off-switch**: "Verify contradiction exists; else output 'No false compromise detected'" - explicit nothing-found output against manufactured findings (agents/inventive_catalyst.md:35,85).
17. **Skill-size guard test** (tests/unit/test_skill_load_limits.py) - SKILL.md kept under a load limit, details pushed to `references/`.

## 4. Strong points and weak points

### Strong (ranked)
1. **Fresh-context reviewer with an artifact-only diet, enforced at harness level** (omitClaudeMd + read-only tools). This is the real mechanism; everything else is packaging. Patrick's ticket-reviewer has the prompt-level version (agents/ticket-reviewer.md:1-8 is a generic prompt with all tools); EGM adds the harness-level enforcement he lacks.
2. **Evidence-bound triage + convergence/settled/churn rules.** Most transferable, well thought out against fresh-reviewer sampling noise. multi-implement's one-exchange cap makes the settled/reopen logic moot unless he ever loops.
3. **Paraphrase-first naive-reader test** - catches "all terms defined but parts do not connect", which a term-list review misses. Cheap, single agent.
4. **Rubrics phrased as a testable principle** ("fresh engineer can do X without guessing"; Zero-Decision Rule; write-allowlist file boundary). Same philosophy as multi-implement's "name a bar, not adjectives".
5. **Doc-vs-code verification persona with severity rules** (contradicts-code = Blocker; proposed files are not findings; require Create/Modify/Delete marking).
6. **Failed reviewer = not run, never zero findings**, and reviewer must read inputs or report incomplete.
7. **Honest docs** (FAQ on velocity; harness table labels what was unverified).

### Weak / gimmick / would not survive real work
- **Cost/latency**: full /egm-review = 5 stages x 1-3 reviewers (+ optional A/B duplicate instances, agents/synthesizer.md:40) + 7-lens brainstorm swarm + loops up to 5 rounds; harness table shows 15-16 reviewers per run, ~8-10 min per fixture (TESTING.md:137-138). Docs say it gives "*a lot* of feedback by design... take what you think is relevant" (docs/getting_started.md). The noise tax lands on the human.
- **Persona theatre**: "hostile", "pedantic compliance officer", TRIZ catalog, Heilmeier standard are mostly flavor. TRIZ is the least grounded persona (33 KB design doc docs/designs/triz_integration.md). The 7-lens brainstorm table (QPS, 3 AM oncall, quota; skills/egm-brainstorm/SKILL.md:92-100) is a generic software-org checklist, poor fit for PLC/industrial work.
- **Software design-doc only**: standards assume a doc with a `## Detailed Implementation Plan` split (egm-review Step 3). Nothing reviews code or diffs.
- **Ceremony**: strict one-question-per-turn gates, JSON preset modals, pause/resume protocols, 400-line skills; `disable-model-invocation: true` everywhere so nothing auto-triggers, and discovery measured poor (docs/verification/skill-discovery-316.md). egm-bootstrap exceeded Antigravity's load limit (TESTING.md:134).
- **Copy-pasted boilerplate**: 13-rule anti-sycophancy block in 3 skills, "Delegation" paragraph in 5. Token tax.
- **Evals are regex-on-string** (test_scenarios.yaml); no evidence of measured reviewer precision/recall; fixture runs verify the workflow executed, not review quality (TESTING.md:152-155 admits this).
- **Windows/permission friction**: reviewers read persona files from the plugin cache, needing Read allow-rules with `//c/Users/...` quirks (docs/claude.md:57-103). Patrick has the plugin installed so he has likely felt it.
- **Adapter indirection**: persona text is two hops away (adapter -> canonical file) = extra Read per reviewer.
- **Bootstrap**: "unbounded" parallel workers; README generation is a one-time need.

## 5. Category tags

| Item | Tag |
|---|---|
| egm-brainstorm | plan-spec |
| egm-draft | plan-spec |
| egm-review | review-qa |
| egm-review-loop | review-qa (loop mechanics also orchestration-implement) |
| egm-resolve | review-qa |
| egm-drift-report | docs-knowledge |
| egm-bootstrap | docs-knowledge |
| egm-comprehension | review-qa |
| egm-design | review-qa |
| egm-zoom-out | review-qa |
| egm-structural | review-qa |
| egm-style | communication-style |
| egm-codebase-details | review-qa |
| egm-implementation-readiness | plan-spec |
| egm-inventive-catalyst | plan-spec (gimmick) |
| egm-synthesizer | context-token-economy |
| egm-bootstrap-orchestrator | orchestration-implement (docs workload) |
| resources/document_standards/* | review-qa |
| resources/execution_instructions.md | plan-spec |
| anti-sycophancy rule block | communication-style |
| .claude-plugin adapters, tests/, scripts/ | skill-authoring-meta |

## 6. Harvestable pieces

H1. Reviewer isolation flags, `.claude-plugin/agents/comprehension.md:4-8`:
```
tools: [Read, Grep, Glob]
model: inherit
color: yellow
omitClaudeMd: true
```
plus body lines 15-17: "Before returning findings, read the target and every supplied standard. If a required file cannot be read, report an incomplete review instead of a verdict." Needs Claude Code >= 2.1.271 (docs/claude.md:8).

H2. Reviewer dispatch rule, docs/claude.md:131-134: "Spawn a new native Agent ... for each independent review... Do not fork the conversation or resume a previous reviewer. Provide only the task, target, persona/standard paths, and explicitly supplied Goldfish context; do not copy parent deliberation."

H3. Paraphrase-first, agents/comprehension.md:37: "**Paraphrase First**: In your own words, write what the document proposes ... If you cannot write a paraphrase of a section, report that section as a Blocker. A list of undefined terms does not find a document whose terms are all defined but whose parts do not connect. The paraphrase does." Output rule line 57: "A wrong paraphrase is a finding."

H4. Zero-Decision Rule + file boundary, resources/document_standards/implementation-readiness-standard.md:12-17, 29-31: plan "must leave zero design or architectural choices to the implementer"; "exact repository-relative file paths to be created, modified, or deleted, suitable for enforcing a ... write allowlist without unapproved adjacent refactors or opportunistic dependency additions."

H5. Fresh-engineer principle (template for any rubric), same file lines 3-8: "passes if a competent engineer (or fresh AI session) who is unfamiliar with the codebase can execute the plan and produce the correct changes on the first attempt, without guessing, asking clarifying questions, or making independent design choices."

H6. Doc-vs-code accuracy rules, agents/codebase_details.md:47-50: "Contradicts the Code ... Report as Blocker: every later reader inherits the false statement. Non-Existent References: ... Check every one. **Proposed files are not findings.** ... If the plan lists files without marking each Create, Modify, or Delete, report that once as Major, and do not flag each path."

H7. Zoom-out reuse rule, agents/zoom_out.md:45: "When a design proposes new utilities, modules, classes, or helper functions, you MUST perform code searches in the codebase to verify whether equivalent or similar components already exist."

H8. Zoom-out standard (resources/document_standards/zoom-out-standard.md): 0 Context Sufficiency (fail fast if objective/why cannot be determined), Root Problem Focus (symptom vs cause), YAGNI/premature optimization, Anti-Weeds altitude control, Leverage Existing.

H9. Style caveat triage, agents/style.md:48: "Classify each flagged sentence as DROP (no concrete reader decision), CALIBRATE (narrow claim to verified scope/evidence), RELOCATE (move operational caveat to the exact step where a user makes a choice), or KEEP". Line 38: "require every claim about existing or tested behavior to match its evidence" (maps onto multi-implement:24-25).

H10. Convergence rules, skills/egm-review-loop/SKILL.md:346-368 (settled / fixed-reopens / clean round / converged = two consecutive / cap 5 / churn).

H11. Resolve guardrails, skills/egm-resolve/SKILL.md:77-82: "Do not contest a comprehension gap. If a fresh reader could not follow the document, the document is missing context." and "Do not change a severity. If you think a Blocker is a Nit, CONTEST it and state the reason."

H12. Failed-reviewer rule, agents/synthesizer.md:31 (already in multi-implement).

H13. Summary-only handoff, agents/synthesizer.md:12-14: aggregator writes a file, returns one message with per-reviewer status + severity counts + path.

H14. "No false compromise detected" escape hatch (agents/inventive_catalyst.md:35): give a reviewer an explicit nothing-found output so it does not manufacture findings.

H15. Draft-vs-brief reconciliation, skills/egm-draft/SKILL.md Step 6.1: list contradictions (quote both), ask the user per item, do not silently conform; report additions only if they change architecture, an external interface, or a dependency. Run by the author context because only it holds both.

H16. Author-decides-architecture, skills/egm-draft/SKILL.md rule 13: up to three options each with mechanism, trade-offs and failure conditions; no ranking, no default; if asked to pick, restate and re-gate.

H17. Drift-report filter, skills/egm-drift-report/SKILL.md:41-43: "Report ONLY the differences ... output 'No drift detected.'" and "If there is some part of the logic that is not referenced in a design or README, this is a reportable drift."

H18. Scout citation rule (bootstrap), skills/egm-bootstrap/SKILL.md:210-219: "Never infer RPC methods, routes, status enums, or invariants from file or directory names alone; cite the exact [file:symbol_or_flag] for every entry." One-liner usable in any code-reading subagent.

H19. Anti-sycophancy block, skills/egm-review/SKILL.md:44-64 (rules 3-10). Highly redundant; a 3-4 line distillation suffices.

## 7. Fit with multi-implement

Patrick's flow: to-spec -> to-tickets -> multi-implement (bar -> slice -> builder/reviewer pair, SendMessage fix round, contest/escalate/decline, one-exchange budget, land).

Already equivalent (no need to port): failed reviewer = not reviewed (multi-implement/SKILL.md:50-51); fix/contest/escalate/decline with checkable evidence (52-66); reviewer is the review, do not review twice (72-73); named bar instead of adjectives (21-22); fresh-context reviewer given only the artifact (47-49). multi-implement is the code-level twin of EGM's doc-level loop and is leaner. Do not adopt EGM's multi-stage swarm for tickets.

Concrete plug-in points:

1. **agents/ticket-reviewer.md**: add harness-level isolation frontmatter `omitClaudeMd: true` (H1). Consider denying Edit/Write (reviewer should not "fix" the builder's code), keeping Bash for running tests, so use a deny list rather than the Read/Grep/Glob allowlist. Add H1's "if a required file cannot be read, report an incomplete review instead of a verdict." Trade-off: omitClaudeMd drops Patrick's CLAUDE.md conventions, so the dispatch prompt must carry the bar and any conventions explicitly (fits the existing step 1 "bar").
2. **ticket-reviewer checklist**: add H6 ("contradicts the code / non-existent reference = Blocker") and H9 ("claim must match evidence") for comments/docs in the diff; extends multi-implement:24-25.
3. **Between to-spec and to-tickets (new small skill or optional step, e.g. `spec-check`)**: one fresh read-only agent runs (a) paraphrase-first (H3), (b) zoom-out reuse code search (H7), (c) zero-decision/ambiguity check (H4/H5, adapted to "could a fresh builder implement ticket N from its text + acceptance criteria without making a design decision?"). One agent, one round, output to `.scratch/<slug>/spec-review.md`, <=15-line summary back (H13). This is the highest-value EGM transplant: it catches ambiguity before N parallel builders each guess differently. Do not port the 5-stage pipeline; at most two lenses (comprehension, readiness).
4. **to-tickets step 4 (quiz the user)**: add a per-ticket readiness probe: acceptance criteria are pass/fail and the file boundary is named (H4). multi-implement step 3 already hands the builder "the files it owns" (line 44); the reviewer can then flag edits outside that allowlist.
5. **multi-implement step 4 (land)**: optional doc-drift check (H17) only if a ticket changed documented behavior; otherwise skip.
6. **Separate skills worth considering**:
   - `spec-review`: 2-persona fresh-context spec reviewer (comprehension paraphrase + readiness/zero-decision), failed-reviewer rule, file + short summary. Tags plan-spec/review-qa.
   - `drift-check` for functional descriptions vs TwinCAT/CoDeSys FBs (H17 + H6 + H18 "cite or it does not count"), pairing with his existing `functional-description` and `review-function-block` skills. Tag docs-knowledge.
   - If he ever adds a multi-round review loop (instead of one exchange), copy H10 verbatim into that skill; otherwise keep the one-exchange budget.
7. **Writing style / caveman / glossary skills**: H9 (DROP/CALIBRATE/RELOCATE/KEEP) is a 4-line addition to a comment/doc-review checklist.
8. **skill-authoring**: take the size-guard idea (keep SKILL.md short, push detail to `references/`); skip the adapter/canonical-persona split (only needed for multi-harness).

Skip: 7-lens brainstorm swarm (software-ops lenses, wrong domain, expensive), TRIZ / Inventive Catalyst, Heilmeier standard, bootstrap (his grill/prototype/codebase-design skills cover it), preset/ask_question modal machinery, multi-harness adapters, A/B duplicate reviewer instances.

Bottom line on "why it works": not the personas. Three load-bearing ideas: (1) the reviewer sees only the artifact, enforced by flags; (2) the author agent adjudicates findings with evidence rules instead of obeying or ignoring them; (3) review output is a file plus a terse summary so the author's context stays clean. multi-implement already implements (2) and (3) at ticket level; harness-level enforcement of (1) and a pre-slicing spec check are the gaps EGM fills.
