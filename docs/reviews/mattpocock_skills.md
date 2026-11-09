# Review: mattpocock/skills (latest main, plugin v1.3.2, last commit 2026-10-31)

Repo path: <clone>/mattpocock_skills
Paths below are relative to that root. Line numbers are from `cat -n` of the file as read.

## 1. What it is

Matt Pocock's personal, curated "daily driver" skill set for Claude Code / Codex / Copilot / Gemini: about 27 promoted skills (engineering + productivity), shipped as a Claude Code plugin (`.claude-plugin/plugin.json`, `marketplace.json`, `mattpocock-skills@claude-plugins-official`) and via skills.sh, plus `in-progress/` (beta), `misc/` (frozen) buckets. Philosophy (README): small, composable, user-owned skills instead of process-owning frameworks (GSD/BMAD/Spec-Kit); the main flow is `grill-with-docs -> to-spec -> to-tickets -> implement | implement-spec -> code-review -> pr -> retro`, routed by the `ask-matt` skill. Mature and very actively maintained: Changesets, CHANGELOG with issue numbers, docs page per skill (`docs/`), `SCOPE.md` + `.out-of-scope/` knowledge base that rejects new-skill proposals, strict repo rules (`AGENTS.md`: no em-dashes, every subagent-dispatching skill must say "fresh context window", every skill is either user-invoked or model-invoked). No hooks/agents/commands directories except one hook script in `misc/`. No tests for the skills (the quality bar is "observed failure in a real session" per `SCOPE.md`).

License: `LICENSE` is **MIT License, Copyright (c) 2026 Matt Pocock** (standard MIT text: permission to use, copy, modify, merge, publish, distribute, sublicense, sell, provided the copyright notice and permission notice are kept in all copies or substantial portions). For Patrick: copying and adapting freely is allowed, including into a private/company skillset, as long as the MIT notice and copyright line travel with substantial copied portions (easy: keep a `CREDITS`/`LICENSE-mattpocock` note in the skill folder or repo). `pr/CREDITS.md` shows Matt's own convention for crediting a derived skill (Dex Horthy `show-me`).

## 2. Inventory

Counts: 20 engineering, 7 productivity, 7 in-progress, 4 misc, 0 deprecated (bucket empty). Every skill also has `agents/openai.yaml` (Codex invocation policy; irrelevant for Claude Code).

### engineering/ (promoted)
| Skill | Path | Invocation | Purpose |
|---|---|---|---|
| ask-matt | skills/engineering/ask-matt/SKILL.md (+PHASE-BOUNDARIES.md) | user | Router/flow map over all skills; phase-boundary decision tree (continue / clear / handoff / subagent / compact) |
| grill-with-docs | skills/engineering/grill-with-docs/SKILL.md | user | 1-line wrapper: invoke `grilling` + `domain-modeling` |
| triage | skills/engineering/triage/SKILL.md (+AGENT-BRIEF.md, OUT-OF-SCOPE.md) | user | Issue/PR state machine (needs-triage/needs-info/ready-for-agent/ready-for-human/wontfix), agent briefs |
| improve-codebase-architecture | skills/engineering/improve-codebase-architecture/SKILL.md (+HTML-REPORT.md) | user | Find "deepening opportunities", HTML report, then grill |
| setup-matt-pocock-skills | skills/engineering/setup-matt-pocock-skills/ (SKILL.md, domain.md, issue-tracker-{github,gitlab,local}.md, triage-labels.md) | user | Per-repo config: tracker, labels, domain-doc layout into `docs/agents/` |
| to-spec | skills/engineering/to-spec/SKILL.md | user | Conversation -> spec (no interview) published to tracker |
| to-tickets | skills/engineering/to-tickets/SKILL.md | user | Spec -> tracer-bullet tickets with blocking edges; wide-refactor expand/contract |
| implement | skills/engineering/implement/SKILL.md | user | Build one ticket/spec: `tdd` -> typecheck -> `code-review` -> commit |
| implement-spec | skills/engineering/implement-spec/SKILL.md | user | Whole spec on an integration branch, subagent per ticket in worktrees, merger subagent, one code-review |
| wayfinder | skills/engineering/wayfinder/SKILL.md | user | Fog-of-war planning of huge efforts as a map of decision tickets |
| retro | skills/engineering/retro/SKILL.md | user | Session retrospective -> suggest *environment* improvements |
| prototype | skills/engineering/prototype/ (SKILL.md, LOGIC.md, UI.md) | model | Throwaway prototype (single HTML logic demo or N UI variants) |
| diagnosing-bugs | skills/engineering/diagnosing-bugs/ (SKILL.md, scripts/hitl-loop.template.sh) | model | 6-phase debug loop gated on a tight red-capable feedback loop |
| research | skills/engineering/research/SKILL.md | model | Background agent, primary sources, cited markdown file |
| tdd | skills/engineering/tdd/ (SKILL.md, tests.md, mocking.md) | model | Red-green loop at pre-agreed seams, anti-patterns |
| domain-modeling | skills/engineering/domain-modeling/ (SKILL.md, GLOSSARY-FORMAT.md, ADR-FORMAT.md) | model | Active glossary + ADR maintenance during design |
| codebase-design | skills/engineering/codebase-design/ (SKILL.md, DEEPENING.md, DESIGN-IT-TWICE.md) | model | Deep-module vocabulary; parallel "design it twice" subagents |
| code-review | skills/engineering/code-review/SKILL.md | model | Two-axis review (Standards + Spec) with parallel subagents, Fowler smell baseline |
| pr | skills/engineering/pr/ (SKILL.md, CREDITS.md) | model | PR body template: Summary visual, Evidence before/after, Merge Danger |
| wizard | skills/engineering/wizard/ (SKILL.md, template.sh) | model | Generate interactive bash wizard for human-only steps |

### productivity/
| Skill | Path | Invocation | Purpose |
|---|---|---|---|
| grill-me | skills/productivity/grill-me/SKILL.md | user | wrapper -> `grilling` |
| grilling | skills/productivity/grilling/SKILL.md | model | Relentless interview: design tree, frontier rounds, recommended answers |
| handoff | skills/productivity/handoff/SKILL.md | user | Handoff doc to OS temp dir, with suggested skills |
| teach | skills/productivity/teach/ (SKILL.md + 4 *-FORMAT.md) | user | Multi-session stateful teaching workspace |
| to-questionnaire | skills/productivity/to-questionnaire/SKILL.md | user | Markdown questionnaire for someone else; "grill the send, not the subject" |
| wait-what | skills/productivity/wait-what/SKILL.md | user | One-line "re-pitch in ASD-STE100 + glossary vocabulary" |
| writing-for-agents | skills/productivity/writing-for-agents/ (SKILL.md, SKILL-MECHANICS.md) | model | Authoring guide for skills/AGENTS.md: context pointers, loads, hierarchy, no-ops |

### in-progress/ (beta, not in plugin)
chief-of-staff (long-running coordinator + LLM wiki), claude-handoff (`claude --bg` seeded handoff), loop-me (workflow-spec grilling), setup-ts-deep-modules (dependency-cruiser rules), software-factory (vocabulary for agent factories + RUNNERS/GIT-HOSTS/TICKET-TRACKERS/OBSERVABILITY/EXAMPLE-TASKS), writing-beats, writing-fragments, writing-shape (article writing trio).

### misc/ (frozen, `.out-of-scope/frozen-misc-skills.md`)
git-guardrails-claude-code (SKILL.md + `scripts/block-dangerous-git.sh`, a PreToolUse hook), migrate-to-shoehorn, scaffold-exercises, setup-pre-commit.

### Other config / scripts
- `.claude-plugin/plugin.json` (skills array = exactly the promoted set), `marketplace.json`.
- `scripts/link-skills.sh` (symlink skills into ~/.claude/skills; dev-only), `scripts/list-skills.sh`, `scripts/sync-plugin-version.mjs`.
- `.github/workflows/{release,needs-info,triage-label}.yml`, issue templates.
- `.agents/` (ADRs, writing-docs.md, invocation.md, install-block.md), `.out-of-scope/*.md` (9 rejection records, e.g. subagent-recursion, new-skills), `docs/` (human docs per skill), `GLOSSARY.md`, `SCOPE.md`, `CONTRIBUTING.md`.
- No agents/ (Claude subagent definitions) and no commands/ in the repo.

## 3. Core mechanisms (with citations)

1. **Invocation split as an architectural rule.** User-invoked skills (`disable-model-invocation: true`) orchestrate and cost zero context; model-invoked skills hold reusable discipline; a user-invoked skill may call model-invoked ones, never another user-invoked one. README "Reference" section; `.agents/invocation.md`; `skills/productivity/writing-for-agents/SKILL-MECHANICS.md:7-14`. Shared reference needed by two user-invoked skills goes to a plain file outside the skill system (SKILL-MECHANICS.md:14). Skills compose via "Call the Skill tool with X" (e.g. `engineering/implement/SKILL.md:11,15`, `grill-with-docs/SKILL.md:7`).
2. **Grilling primitive = design tree + frontier rounds.** `productivity/grilling/SKILL.md:6-30`: ask the *whole frontier* each round, numbered Q + recommended answer, "Word each question so 'yes' accepts your recommended answer" (l.24), facts via fresh-context subagent while decisions wait for the user (l.28), done when frontier empty (l.30). Reused by grill-me, grill-with-docs, triage, wayfinder, improve-codebase-architecture.
3. **Feedback-loop-first debugging with a hard gate.** `engineering/diagnosing-bugs/SKILL.md:18-66`: 10 ordered loop recipes (l.26-35), "tighten the loop" (l.41-47), completion criterion = one already-run command that is red-capable/deterministic/fast/agent-runnable (l.59-64), "No red-capable command, no Phase 2" (l.66). Then minimise until every element is load-bearing (l.80-86), 3-5 falsifiable ranked hypotheses shown to the user (l.90-98), tagged `[DEBUG-xxxx]` logs (l.110), regression test only at a "correct seam", else absence of seam is the finding (l.116-120), cleanup checklist incl. grep prefix and stating the true hypothesis in the commit (l.132-138). Mutation-proof rule new (l.125). Redaction rule (l.12-16).
4. **Two-axis review with parallel fresh-context subagents.** `engineering/code-review/SKILL.md:6-12,58-80`: pin fixed point with three-dot diff and validate it before spawning (l.17-23); spec source discovery order (l.25-32); Standards agent gets docs + a 12-item Fowler smell baseline as judgement calls that repo docs override (l.38-56); Spec agent reports missing / scope creep / wrong (l.72); reports are *not* merged or reranked (l.78-80, rationale l.82-89); skip spec agent if no spec.
5. **Orchestration by task graph + context pointers.** `engineering/implement-spec/SKILL.md:11-19,21-41`: tickets are a graph with a frontier (l.13); fresh context per subagent (l.15); sparse communication via context pointers (l.17); optional exploration subagent writing notes outside the repo (l.25); integration branch (l.11,27); each implementer in its own worktree, verifies base == integration branch, runs `tdd`, merges integration tip into its branch before reporting (l.29-32) so merges are fast-forwards; merger subagent (l.34); re-evaluate frontier after each merge (l.36); one code-review then fixes by a *single fresh implementer* (l.38); cleanup worktrees (l.42).
6. **Seam discipline in plan and test.** `to-spec/SKILL.md:15-17` (sketch test seams first, prefer existing, "ideal number is one", confirm with user), `tdd/SKILL.md:20-26` (test only at pre-agreed seams; each seam gets a one-line "what it catches / what it misses" note, new upstream), anti-patterns incl. tautological tests and horizontal slicing (tdd/SKILL.md:30-32, tests.md), "interface is the test surface" and deletion test (`codebase-design/SKILL.md` Principles).
7. **Ticket shape and slicing rules.** `to-tickets/SKILL.md:29-40`: vertical slices, each demoable and sized for one fresh context window, prefactor first ("make the change easy, then make the easy change", l.23), blocking edges explicit, wide refactors as expand-migrate-contract with blast-radius batches (l.40); quiz the user on granularity and edges (l.42-56); one file per ticket under `.scratch/<feature>/issues/NN-slug.md` for local tracker (l.62, template l.69-82). Tickets avoid file paths/snippets since they go stale (l.105).
8. **Agent brief durability rules.** `engineering/triage/AGENT-BRIEF.md`: "Durability over precision", behavioural not procedural, complete testable acceptance criteria, explicit out-of-scope, template with Current/Desired behaviour, Key interfaces.
9. **Environment-improvement retro.** `engineering/retro/SKILL.md:15-23,29-35`: categories (navigation pointers, automated checks, coding standards, global AGENTS.md bloat, tool economy, no-ops, information access); mechanical violation -> deterministic check, judgement call -> CODING_STANDARDS.md; reviewer (least context pressure) enforces standards, implementer does not (l.31-35).
10. **Context-economy theory baked into skills.** `ask-matt/PHASE-BOUNDARIES.md` (ordered 5-question tree; "smart zone ~150k tokens"; primary vs secondary sources; compact is the default of last resort); `writing-for-agents/SKILL.md:12-27` (context pointer, context load vs cognitive load), l.45-52 (completion criteria clarity + demand; sequence-splitting to avoid premature completion), l.61-74 (leading words, negation failure), l.76-81 (single source of truth, environment-as-source-of-truth, no-ops).
11. **Fog-of-war planning.** `wayfinder/SKILL.md:19-26` (map is an index, not a store), l.57 (ticket sized to ~100K-token session), l.75-80 (HITL vs AFK, 4 ticket types), l.82-93 (fog vs ticket test: "can you state the question precisely, not answer it"), l.105 (one ticket per session), l.114 (create then wire edges in a second pass; no placeholder `#<n>`).
12. **Domain glossary + ADR gate.** `domain-modeling/SKILL.md:44-74`, `GLOSSARY-FORMAT.md:25-30` (opinionated, `_Avoid_:` synonyms, project-specific terms only), `ADR-FORMAT.md:29-37` (offer ADR only if hard to reverse AND surprising AND real trade-off).
13. **Chief-of-staff wiki discipline.** `in-progress/chief-of-staff/SKILL.md:26-47`: index.md + one page per topic, ingest/query/lint, "write history not the present": every claim dated, code claims cite commit.
14. **Hook example.** `misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh`: PreToolUse on Bash, regex list (push, reset --hard, clean -f, branch -D...), exit 2. Frozen, known bypasses (`git -C`, no-jq fails open; `.out-of-scope/frozen-misc-skills.md`). Also needs `jq` (not on stock Windows).
15. **Human-in-loop bash loop.** `diagnosing-bugs/scripts/hitl-loop.template.sh` (`step`, `capture`, prints KEY=VALUE); `wizard/template.sh` (stage-based interactive wizard; WSL-aware URL opening).

## 4. Strong points (ranked) and weak points

### Strong
1. **diagnosing-bugs**: the "red-capable loop before any hypothesis" gate with an explicit, checkable completion criterion is the best-articulated debugging discipline in the set; maps directly to PLC/commissioning work (replace "curl" with a forced-input/simulation replay).
2. **code-review two-axis split + pre-validated fixed point + Fowler smell baseline**: cheap, parallel, deliberately unmerged findings; the fixed-point/empty-diff check before spawning prevents wasted subagents.
3. **tdd seam agreement + anti-pattern list (tautological tests, horizontal slicing, implementation-coupled)**: short and sharp; the tautological-test rule applies equally to PLC unit tests (expected values from spec, not recomputed).
4. **to-tickets slicing rules, including expand-contract for wide refactors and "fits one fresh context window"**: directly improves ticket quality for multi-implement.
5. **writing-for-agents** (completion criteria clarity/demand, no-ops, negation, pointers, single source of truth): the best meta-skill here, and Patrick's own SKILL.md files already follow its style.
6. **retro** (environment not code; mechanical -> check, judgement -> standards): cheap, high-leverage close-the-loop skill; Patrick already has a byte-identical local copy.
7. **ask-matt PHASE-BOUNDARIES**: concrete, ordered rule for clear/compact/handoff/subagent decisions.
8. **grilling**: frontier rounds + recommended answers is a good interview protocol; the "yes accepts recommendation" wording is a nice small trick.
9. **AGENT-BRIEF durability rules**, **pr "Merge Danger" (one-way/two-way door + blast radius)**.

### Weak / gimmicks / won't survive real work
- **Built around GitHub/GitLab issue trackers** (setup skill, `ready-for-agent` labels). Patrick's tracker is Jira; local `.scratch` file mode exists but his multi-implement flow already assumes "the project's issue tracker". Nothing here knows Jira.
- **implement-spec is brittle for his stack**: worktree-per-ticket + merger subagent + integration branch assumes mergeable text code and a fast typecheck/test cycle; TwinCAT/CoDeSys XML project files (.TcPOU etc.) and binary-ish PLCopen files merge badly, and "tsc --build" concerns don't apply. Its reviewer step is a single code-review at the end, with no per-ticket review, and fixes go to a *fresh* implementer (opposite of Patrick's "same builder via SendMessage is cheaper" insight in `multi-implement` step 3).
- **No evidence the skills are tested** beyond Matt's usage; "observed failure" gate only. Some of the best material is prose-only judgement (no verification scripts).
- **Heavy dependency on Skill-tool chaining** (`Call the Skill tool with "tdd"`): fine in Claude Code but means copied skills must keep sibling names, and `disable-model-invocation` skills cannot be called by other skills (Matt works around this by reading by relative path in chief-of-staff: `chief-of-staff/SKILL.md:51-54`).
- **TypeScript-centric examples** (tests.md, mocking.md, setup-ts-deep-modules, shoehorn, dependency-cruiser). The principles port; the examples do not.
- **`to-spec` asks for "a LONG, extensive list of user stories"** (to-spec/SKILL.md:33-41): token-heavy and arguably padding for PLC modules; and bans file paths/snippets in specs (l.55), which conflicts with PLC specs that must name FB/IO/variable tags.
- **wayfinder, chief-of-staff, software-factory, loop-me, wiki**: sophisticated but speculative/in-progress or "most cognitively demanding" (Matt's own words); unlikely to be used daily by Patrick. software-factory is a glossary only.
- **ask-matt is 12.7 KB** and must be maintained by hand in step with every skill change (`AGENTS.md` rule); a router that drifts "lies" (his own words). Not needed if Patrick keeps a small skill set.
- **git-guardrails hook**: regex bypassable, needs jq, frozen. Prefer Claude Code `permissions.deny` rules.
- **improve-codebase-architecture HTML report** (Tailwind + Mermaid CDN): nice for web repos, low relevance to PLC.
- Em-dash ban etc. are repo-hygiene, not behaviour.

## 5. Category tags

| Item | Tag |
|---|---|
| to-spec | plan-spec |
| to-tickets | plan-spec |
| wayfinder | plan-spec |
| grilling / grill-me / grill-with-docs | plan-spec |
| loop-me | plan-spec |
| to-questionnaire | plan-spec |
| triage (+AGENT-BRIEF, OUT-OF-SCOPE) | plan-spec |
| implement | orchestration-implement |
| implement-spec | orchestration-implement |
| chief-of-staff | orchestration-implement |
| software-factory | orchestration-implement |
| tdd | orchestration-implement (test-first build discipline; secondary review-qa) |
| code-review | review-qa |
| pr | review-qa |
| retro | review-qa (secondary skill-authoring-meta) |
| diagnosing-bugs (+hitl-loop.template.sh) | debugging |
| ask-matt, PHASE-BOUNDARIES | context-token-economy |
| handoff / claude-handoff | context-token-economy |
| research | docs-knowledge |
| domain-modeling (+GLOSSARY/ADR-FORMAT) | docs-knowledge |
| setup-matt-pocock-skills | docs-knowledge (repo config; tracker-specific) |
| codebase-design (+DEEPENING, DESIGN-IT-TWICE), improve-codebase-architecture | domain-other (software design) |
| prototype | domain-other |
| wait-what | communication-style |
| teach | communication-style (learning) / domain-other |
| writing-for-agents (+SKILL-MECHANICS) | skill-authoring-meta |
| wizard (+template.sh) | domain-other (human-in-loop procedures) |
| writing-beats / writing-fragments / writing-shape | communication-style |
| setup-ts-deep-modules, migrate-to-shoehorn, scaffold-exercises, setup-pre-commit | domain-other |
| git-guardrails-claude-code (+hook script) | domain-other (safety hook) |

## 6. Harvestable pieces

(Quotes are short, from the files cited.)

1. **Hard gate for debugging** (`skills/engineering/diagnosing-bugs/SKILL.md:59-66`): "name **one command** ... that you have **already run at least once**" and is red-capable / deterministic / fast / agent-runnable; "No red-capable command, no Phase 2." Plus l.80-86 minimise: "every remaining element is load-bearing". Plus l.125 diff-against-pristine to prove a forced red.
2. **Falsifiable hypothesis format** (l.92-98): `If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse.` Show ranked list to user before testing.
3. **Tagged debug instrumentation** (l.110): unique `[DEBUG-a4f2]` prefix so cleanup is one grep. PLC analogue: tagged temporary trace/log variables.
4. **Smell baseline + overrides** (`code-review/SKILL.md:38-56`): 12 Fowler smells each as "what -> how to fix", always judgement calls, repo standards override.
5. **Reviewer briefs** (l.66, l.72): Standards: "cite the standard (file + the rule)... Distinguish hard violations from judgement calls... Under 400 words." Spec: "(a) missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) looks implemented but wrong. Quote the spec line for each finding."
6. **Fixed-point precheck** (l.17-23): `git diff <fixed-point>...HEAD`, `git rev-parse`, non-empty diff "should fail here, not inside two parallel sub-agents".
7. **Seam note** (`tdd/SKILL.md:24`): "Give each proposed seam a one-line note on what it catches and what it misses." Anti-patterns l.30-32 and tests.md GOOD/BAD pairs; "Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec."
8. **Ticket slicing rules** (`to-tickets/SKILL.md:29-36`): complete vertical path; "demoable or verifiable on its own"; "sized to fit in a single fresh context window"; "Any prefactoring should be done first". Wide-refactor expand/migrate/contract paragraph (l.40) for big mechanical changes (e.g. renaming a shared FB/type across a TwinCAT library).
9. **Agent-brief rules** (`triage/AGENT-BRIEF.md:Principles`): durability over precision, behavioural not procedural, complete acceptance criteria "each independently verifiable", explicit "Out of scope" block, template with Current/Desired behaviour, Key interfaces.
10. **Subagent hygiene lines** (`implement-spec/SKILL.md:15-17`): "Start every subagent with a fresh context window." and "Communicate primarily through context pointers ... Don't duplicate information already available via pointers." Also worktree base check (l.30) and merge integration tip before reporting (l.32).
11. **Grilling round format and rules** (`grilling/SKILL.md:8-28`): frontier rounds, `Q# - title`, recommended answer, "Word each question so 'yes' accepts your recommended answer", "Finding facts is your job, never the user's".
12. **Phase boundary tree** (`ask-matt/PHASE-BOUNDARIES.md`, five questions in order; compact only last; "Clear a relevant context and you lose the why"). Directly usable inside multi-implement between spec/tickets/build phases.
13. **Retro categories and the mechanical-vs-judgement rule** (`retro/SKILL.md:19`) and "implementation agent has the most context pressure; review agent should impose coding standards" (l.31-35). Supports Patrick's pair design (reviewer gets only the artifact).
14. **PR template** (`pr/SKILL.md:14-33,152-170`): Summary visual (pseudocode / call tree / file tree / diff), Evidence Before/After ("Screenshots are S-tier; execution-based evidence is A-tier"), Merge Danger (one-way/two-way door + one-word blast radius). Very suitable for PLC change summaries (state-machine diff, before/after sim trace).
15. **ADR gate** (`ADR-FORMAT.md:29-37`) and **GLOSSARY format** with `_Avoid_:` (`GLOSSARY-FORMAT.md:12-30`): Patrick already has a controlled-vocabulary `glossary` skill; the `_Avoid_` convention matches it.
16. **writing-for-agents rules** (`writing-for-agents/SKILL.md:47-52,76-81`): "The strongest criteria are both checkable and exhaustive." Hunt no-ops; "restating the environment is a cache"; negation failure mode: prompt the positive.
17. **Wiki "write history, not the present"** (`chief-of-staff/SKILL.md:42-47`) for any persistent notes file (dated claims, cite commit).
18. **Prototype capture rule** (`prototype/SKILL.md:26`, `to-tickets/SKILL.md:105`): keep decision-rich snippet inline in spec/ticket when prose cannot encode it (state machine, schema, type shape). Good for PackML state tables.
19. **HITL script template** (`diagnosing-bugs/scripts/hitl-loop.template.sh`) for commissioning-style "human must click/observe" repros.
20. **`to-questionnaire` "grill the send, not the subject"**: handy for asking a customer/electrician/mechanical engineer for missing facts.

## 7. Fit with multi-implement

Flow: `to-spec -> to-tickets -> multi-implement (bar -> slice -> builder+reviewer pair -> land) -> ticket-builder / ticket-reviewer`.

- **to-spec (local copy identical to upstream)**: add the "seam" step already present (l.15-17); optionally add the retro-style tweak "each seam: one line on what it catches/misses" there too so the seam list carries through to tickets. Consider lifting the "LONG list of user stories" demand (l.33-41) for PLC specs; replace with a requirements list that may name FB/tag names.
- **to-tickets**: harvest (a) "sized for one fresh context window" is already local; (b) add the agent-brief durability rules and "Out of scope" block to the ticket template (item 9) so builders get explicit scope fences; (c) add a per-ticket "Bar / exemplar" line (Patrick's step 1 of multi-implement pins a bar per ticket; letting to-tickets propose the exemplar path would feed it directly); (d) keep upstream's new native-blocking/sub-issue wording only if using GitHub; for Jira use issue links "is blocked by".
- **multi-implement step 1 (bar)**: seam note from tdd ("catches / misses") and "expected values from an independent source" can become bar-check lines. The Spec-axis brief (quote the spec line per finding) fits the bar concept.
- **multi-implement step 2 (slice)**: from implement-spec: worktree base check ("confirm its worktree is based on the integration branch ... resets onto it if not") and "merge integration tip into your branch before reporting done". Only worth it if parallel builders merge onto one integration branch. Otherwise leave out (Patrick's design is lighter).
- **ticket-builder.md**: currently a bare stub. Add: "Start from a fresh context; receive ticket + bar + owned files as pointers, not copies"; use `tdd` at agreed seams; run typecheck/single-file tests during work, full suite once; stop uncommitted at green; report fixed point. Add the tautological-test and horizontal-slicing rules (compact). Add `diagnosing-bugs` gate line for when a test stays red: "build a red-capable command before theorising".
- **ticket-reviewer.md**: currently a bare stub. Add the code-review reviewer briefs (item 5): cite standard file+rule, hard vs judgement, smell baseline (judgement-only, repo overrides), spec axis (missing / scope creep / looks-right-but-wrong, quote spec line), "Under 400 words", skip tooling-enforced items. Keep two axes separate, do not merge/rerank. Pre-validate the fixed point (item 6) in multi-implement step 3.2 before dispatch.
- **multi-implement step 4 (land)**: add pr "Merge Danger" and "Evidence before/after" to the report or PR body; follow-up issues format from agent brief template.
- **After landing**: `retro` (already local) as an optional step 5 "Retro" on a run that went sideways: feed findings into CODING_STANDARDS.md/ticket-reviewer standards (this is the Matt loop: mechanical -> lint/check, judgement -> reviewer standards).
- **Phase boundaries**: PHASE-BOUNDARIES.md can be inlined as a short rule in multi-implement's preamble ("keep spec+tickets in one window; builders start fresh; clear/compact only at boundaries").
- **Separate skills worth importing**: (1) `diagnosing-bugs` (already local; update with the diff line), (2) `pr` (already local; PLC adaptation), (3) `to-questionnaire` (new, small, high utility), (4) `git-guardrails` as a `permissions.deny` snippet rather than the hook, (5) `wizard` (already local), (6) `chief-of-staff` wiki convention only as text if Patrick keeps persistent notes. Skip: wayfinder, software-factory, loop-me, writing-* trio, ts/pre-commit/shoehorn/scaffold, setup-matt-pocock-skills (GitHub-centric) unless wanted.
- **Where Patrick is ahead of Matt**: multi-implement keeps the builder alive and sends findings via SendMessage (cheaper), has the contest/escalate/decline triage of findings, a single exchange budget, per-ticket bar, "reviewer never receives builder's account", and "did not review => not reviewed" handling. Matt's `implement-spec` has none of that (one global review, fresh implementer for fixes). Upstream confirms the fresh-per-ticket stance (`.changeset/implementer-fresh-per-ticket.md`): fresh implementer for each ticket and for review fixes. That is a deliberate contrary choice; keep Patrick's.

## 8. Diff vs Patrick's local copies

Local copies in C:/Users/patrickk/.claude/skills (dated 2026-09-23 for the Matt set). Compared with `diff -r` ignoring `agents/openai.yaml`.

### New upstream (not in Patrick's skills)
- `engineering/ask-matt` exists locally (changed, see below).
- NEW: `in-progress/chief-of-staff`, `in-progress/software-factory` (+5 reference files), `misc/git-guardrails-claude-code`, `misc/migrate-to-shoehorn`, `misc/scaffold-exercises`, `misc/setup-pre-commit`. (The misc four are frozen/old, not truly new this cycle; Patrick simply never copied them.)
- Local `loop-me`, `setup-ts-deep-modules`, `writing-beats/-fragments/-shape`, `grill-me`, `grill-with-docs`, `prototype`, `retro`, `to-spec`, `to-questionnaire`, `writing-for-agents`: byte-identical to upstream (apart from openai.yaml).

### Removed upstream
- **`resolving-merge-conflicts`**: removed (CHANGELOG, PR #1120): "It's no longer needed, and nothing replaces it: the agent works through an in-progress merge or rebase conflict without a dedicated skill." Patrick's local copy is orphaned (decide whether to keep; it is also listed in the local available-skills list). Router entry removed from ask-matt.
- `deprecated/` bucket is empty (older removals: caveman, zoom-out, write-a-skill, to-prd/to-issues/to-plan etc. are already gone locally, aside from Patrick's own unrelated `caveman` plugin).

### Materially changed (upstream is newer)
Global theme: **`CONTEXT.md`/`CONTEXT-MAP.md` renamed to `GLOSSARY.md`/`GLOSSARY-MAP.md`** across domain-modeling (file `CONTEXT-FORMAT.md` -> `GLOSSARY-FORMAT.md`), grill-with-docs, improve-codebase-architecture, setup-matt-pocock-skills (+domain.md), triage, tdd, diagnosing-bugs, ask-matt, codebase-design (DESIGN-IT-TWICE), wait-what, pr (CHANGELOG PR #1120). Setup skill now offers `git mv` of legacy files. Note Patrick's own `glossary` skill is Blueprint's controlled vocabulary, so adopting the new name is optional; keep consistent with whichever filename his repos use.

Second theme: **"Start every subagent with a fresh context window"** added to implement-spec, code-review, codebase-design/DESIGN-IT-TWICE, improve-codebase-architecture, wayfinder, research, grilling, chief-of-staff (PR #1341). Rationale: Codex forks parent context by default.

Per skill:
- **implement** (changed): upstream adds "If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask." (l.9) and replaces bare `/tdd`, `/code-review` with "Call the Skill tool with "tdd"/"code-review"" (l.11,15). Otherwise identical (5 behaviours: tdd at pre-agreed seams, typecheck often, single tests often, full suite once, code-review, commit). Patrick's local copy has the old bare slash form; his multi-implement depends on `/implement` for the single-ticket case, so the ticket-title echo is the useful part.
- **implement-spec** (substantially changed): description now "Implement the result of /to-spec and /to-tickets in code". Goal changed from "a PR" to "entire spec on a single **integration branch**, every ticket resolved the way the issue tracker closes work" (l.11); draft PR only if the tracker closes work through PRs or user asks and only after first merge (l.27, a branch with no commits ahead of main can't open one); "Start every subagent with a fresh context window" (l.15); implementer steps now explicit: confirm worktree based on integration branch, call Skill `tdd`, merge integration tip into own branch before reporting done (l.29-32); code-review fixes go to "a single fresh implementer subagent" (l.38) and changeset says fresh implementer per ticket; step 8 conditional (mark PR ready, else resolve tickets and report branch). Graduated from in-progress to engineering (#1120) and is now routed by ask-matt.
- **to-spec**: unchanged (identical).
- **to-tickets** (minor): real-tracker branch now says "Use the platform's native blocking relationship ... If the source was an existing issue, make each ticket its sub-issue (tracker doc's operation)" (l.63); issue-template "Blocked by" notes "Omit this section when blockers were set as native edges" (l.101). Rest (vertical slice rules, wide refactor expand-contract, quiz step, local ticket template) identical.
- **code-review** (minor, same algorithm): removed hard-coded `docs/agents/issue-tracker.md` references ("tracker doc"); standards sources step reworded to "Search the repo for every file that documents how code should be written. When CODING_STANDARDS.md or CONTRIBUTING.md exists, it must be on the list." (l.36); new line "Issue both sub-agent calls together, in the foreground, and aggregate the reports they return." (l.60); fresh context (l.11). Fowler smell baseline already present locally.
- **diagnosing-bugs** (minor): `CONTEXT.md` -> `GLOSSARY.md`; one new rule in Phase 5 step 2: "If you forced the red by mutating code or a fixture, `diff` against a pristine copy to prove the mutation landed before you trust it." (l.125). The big structure (redact section, tight red-capable loop gate, minimise, hypotheses, tagged logs, seam finding) was already in Patrick's copy; Phase 6 hand-off to improve-codebase-architecture was removed earlier (PR in CHANGELOG ~l.100).
- **tdd** (minor): `GLOSSARY.md`; seam proposals now need "a one-line note on what it catches and what it misses" (l.24). Tautological-test rule and structure already present locally.
- **grilling** (minor): new rule "Word each question so "yes" accepts your recommended answer." (l.24); sub-agent "with a fresh context window" (l.28).
- **domain-modeling**: rename only (+ description trigger now covers editing GLOSSARY.md / ADR).
- **research**: only "Start it with a fresh context window."
- **improve-codebase-architecture**: rename + fresh-context subagent.
- **triage**: rename only.
- **wayfinder**: wayfinder labels are the only labels on map/tickets, never `ready-for-agent` (l.65); cross-references wired in second pass with real ids, "a placeholder `#<n>` auto-links to an unrelated issue" (l.114); research subagent fresh context, push branch but open no PR (l.115); resolve by reading the `wayfinder:<type>` label, "the body never states the type" (l.124).
- **ask-matt** (moderate): new rule "Before stating what a skill does or recommending a step be skipped, read that skill's SKILL.md" (l.11); main flow now offers `/implement` per ticket OR `/implement-spec` for whole spec; adds `/pr` and `/retro` as flow step 4 and in on-ramps (diagnosing-bugs now points to `/retro`); resolving-merge-conflicts removed; "Run /retro in the session it's looking back on, before you clear".
- **pr**: rename `GLOSSARY.md`; the component-tree code fence fixed (`text` not `tsx`); CREDITS wording reflects that only the Summary visuals menu derives from Dex Horthy's show-me.
- **handoff**: now names Windows temp dir (`%TEMP%`) explicitly. Relevant for Patrick.
- **claude-handoff** (in-progress): saves summary to temp file then `claude --bg --name ... -- "$(cat <file>)"` to avoid shell expansion of backticks/`$`.
- **teach**: workspace-path clarification; quiz answer position must vary ("Vary which position holds the correct answer").
- **wait-what**: rename only.
- **codebase-design**: DESIGN-IT-TWICE rename + fresh context.
- **setup-matt-pocock-skills**: rename, legacy file `git mv` offer, ensure git remote reachable for GitHub/GitLab, create missing labels (`gh label create`); GitHub template: native blocking via `gh issue create --blocked-by`/`--add-blocked-by` (gh 2.94+), count-open-blockers command, `--parent` sub-issues, "never file into mattpocock/skills", comment before close. GitLab template tweaks. Not relevant unless Patrick uses these trackers.
- **wizard/template.sh**: robustness fixes: `tput clear` fallback, no `RED`, `_existing` now decodes single/double-quoted `.env` values, readline-based `ask`, EOF handling, browser-open failure handling. Worth refreshing the copy (cheap, strictly better).
- **Unchanged (byte-identical besides openai.yaml)**: grill-me, grill-with-docs, prototype, retro, to-spec, to-questionnaire, writing-for-agents, loop-me, setup-ts-deep-modules, writing-beats/-fragments/-shape.

### Recommended actions for Patrick
1. Take upstream `implement` (ticket-title echo, Skill-tool calls) and `diagnosing-bugs` diff line, `tdd` seam note, `grilling` "yes accepts" line, `handoff` Windows temp wording: all small and strictly better.
2. Decide on GLOSSARY vs CONTEXT naming once; if switching, apply to domain-modeling, tdd, diagnosing-bugs, triage, wait-what, pr, improve-codebase-architecture, setup.
3. Do not take upstream `implement-spec` over multi-implement; harvest only worktree base check and merge-tip-before-report if parallel builders merge to an integration branch.
4. Decide on orphaned `resolving-merge-conflicts` (no upstream replacement; keep as personal skill or delete).
5. Refresh `wizard/template.sh`.
6. Consider adding `to-questionnaire`-style prompts and `retro` as step 5 of multi-implement; fill the empty `ticket-builder.md` / `ticket-reviewer.md` stubs with the briefs in section 7.
