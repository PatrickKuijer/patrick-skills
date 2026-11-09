# Review: DietrichGebert/ponytail (v5.3.3)

Repo root: <clone>/DietrichGebert_ponytail
(Paths below are relative to it.)

## 1. What it is

A "lazy senior dev" anti-overengineering persona for coding agents. The core is ONE prompt (`skills/ponytail/SKILL.md`, ~3.5 KB; compact copy `AGENTS.md`): a 6-rung "smallest complete change" ladder (needs to exist? -> already in codebase -> stdlib/platform -> installed dep -> one line -> minimum code), a "never cut" list (trust-boundary validation, data-loss handling, security, a11y, hardware calibration), a test reflex for non-trivial logic, and a `shortcut: <limit>, <upgrade trigger>` comment convention. Around it: two report skills (`ponytail-review` diff review, `ponytail-audit` whole-repo audit), `ponytail-debt` (greps shortcut markers into a ledger), `-gain`/`-help` (static display cards). Everything else (~80% of the repo) is distribution plumbing for ~20 agents (Claude Code, Codex, Cursor, Copilot, Windsurf, Kiro, OpenCode, pi, ...), Node hooks, a Claude Code "band" TUI/cost board, benchmark harness, marketing assets, i18n READMEs.

Maturity: high polish, very active (issue numbers up to #1157 cited in code comments), CI (`.github/workflows/test.yml`), a rule-drift checker, a published agentic benchmark (39 tasks x 5 runs, Opus 5.5; self-run by the author, Bash disabled for all arms). Contribution policy: ruleset changes require a 3-arm benchmark (`.github/CONTRIBUTING.md`).

License: `LICENSE` = standard MIT, "Copyright (c) 2026 DietrichGebert". Allows copying, modifying, redistributing, commercial/private use; the only condition is keeping the copyright + permission notice in copies or substantial portions. Adapting prompt text into personal skills is fine; keep a one-line credit + license note in the skill folder.

## 2. Inventory (with section 5 category tags)

| Item | Path | Purpose | Tag |
|---|---|---|---|
| skill `ponytail` | skills/ponytail/SKILL.md | Always-on lazy-senior ruleset; levels lite/full/ultra | communication-style (build discipline; also orchestration-implement flavored) |
| rules copy AGENTS.md + 7 synced copies (.cursor, .windsurf, .clinerules, .agents, .qoder, .kiro, .github/copilot-instructions.md) | AGENTS.md etc. | Compact ruleset for rule-file agents | skill-authoring-meta |
| skill `ponytail-review` | skills/ponytail-review/SKILL.md | Diff review: bug/risk/scale/missing test/speed/lean; plain-English 4-part findings | review-qa |
| skill `ponytail-audit` | skills/ponytail-audit/SKILL.md | Whole-repo version, map-first, <=20 ranked findings | review-qa |
| skill `ponytail-debt` | skills/ponytail-debt/SKILL.md | `git grep` shortcut markers -> debt ledger, `no-trigger` rot flag | docs-knowledge |
| skill `ponytail-gain` | skills/ponytail-gain/SKILL.md | Static ASCII benchmark scoreboard, "never print per-repo savings" rule | context-token-economy (marketing) |
| skill `ponytail-help` | skills/ponytail-help/SKILL.md | Reference card | docs-knowledge |
| commands x6 | commands/*.toml | Gemini-style one-line prompt versions of the skills | skill-authoring-meta |
| OpenClaw copies | .openclaw/skills/*, scripts/build-openclaw-skills.js, publish-openclaw-skills.js | Generated skill copies for another host | skill-authoring-meta |
| OpenCode adapter | .opencode/command/*.md, .opencode/plugins/* | Host adapter | domain-other |
| hook SessionStart | hooks/ponytail-activate.js | Writes mode flag, injects filtered ruleset + codebase map, statusline nudge | context-token-economy |
| hook SubagentStart | hooks/ponytail-subagent.js | Injects ruleset into every subagent (SessionStart context never reaches them); optional regex matcher env | orchestration-implement |
| hook UserPromptSubmit | hooks/ponytail-mode-tracker.js | Parses `/ponytail lite/full/ultra/off`, "stop ponytail", persists mode | domain-other |
| instructions builder | hooks/ponytail-instructions.js | Strips frontmatter, filters mode rows from SKILL.md | skill-authoring-meta |
| codebase map | hooks/ponytail-map.js | Regex map of top-level symbols, one line per dir, 2000-char budget, shared dirs first; injected at session start so "reuse first" needs no search | context-token-economy |
| config/runtime/import | hooks/ponytail-config.js, ponytail-runtime.js, ponytail-band-import.js | Config resolution (env > file > default), host detection, past-session import | domain-other |
| statusline | hooks/ponytail-statusline.sh/.ps1 | Mode badge | domain-other |
| band | hooks/band/{register.tsx,metrics.ts,board.ts,logo.ts}, hooks/claude-band.json | Claude Code TUI band: cost/tokens/agent time/reuse%/tests-passed, per-project CSV ledger, local board page, optional https webhook | context-token-economy |
| pi extension | pi-extension/ | Host adapter + tests | domain-other |
| plugin manifests | .claude-plugin, .codex-plugin, .devin-plugin, .kimi-plugin, .qoder-plugin, .grok-plugin, .github/plugin, gemini-extension.json, plugin.json/yaml | Multi-host packaging | domain-other |
| scripts | scripts/check-rule-copies.js, check-versions.js, cursor-hooks.js, uninstall.js | Drift/version guards, installers | skill-authoring-meta |
| tests | tests/*.test.js(x) | Hook/adapter tests + behavior/correctness gates | skill-authoring-meta |
| benchmarks | benchmarks/ (promptfoo configs, arms/, agentic/{run,judge,tasks}.py, results/*.md) | A/B harness: baseline vs caveman vs ponytail, hidden checks, injected-bug test-quality scoring | skill-authoring-meta |
| examples | examples/*.md (12 before/after) | Verbatim with/without outputs | docs-knowledge |
| docs | docs/agent-portability.md, cursor-hooks.md, INSTALL.md, after-install.md | Host porting notes | domain-other |

No agents/ directory (no subagent definitions); the only subagent mechanism is the SubagentStart prompt injection.

## 3. Core mechanisms

1. First-rung-that-holds ladder: skills/ponytail/SKILL.md:21-29 (six ordered options); reuse-before-write is the lead rung after "does it need to exist".
2. Scope-first, lazy-second: SKILL.md:17-19 "List every place your change must reach: callers, tests, fixtures, config, exports"; line ~33 "Be lazy about the solution, never about the change itself". Prevents minimalism turning into skipped callers.
3. Explicit never-cut carve-out: SKILL.md:~44 (trust-boundary validation, data-loss handling, security, a11y, hardware calibration). README claims 30/30 on six security tasks (benchmarks/results/2026-10-07-agentic.md ~line 69).
4. Bug-fix rule: SKILL.md:~38 "grep every caller of the function you touch, then fix the root cause once in the shared code"; guarded by the INVARIANTS canary in scripts/check-rule-copies.js.
5. Test reflex with a trigger definition: SKILL.md:~41 "new non-trivial logic (a branch, a loop, a parser, money or security...) leaves one small test or an assert-based self-check. Trivial changes need none."
6. Deferral ledger: `shortcut: <limit>, <upgrade trigger>` comment (SKILL.md:~42) + skills/ponytail-debt/SKILL.md:18 grep, `no-trigger` rot tag (:36-37). Reviewer/auditor treat a marked shortcut as a decision, not a finding (review SKILL.md:63-64, audit :63-64).
7. Review prompt structure, skills/ponytail-review/SKILL.md: (1) understand first incl. grep callers of changed signatures (:21-29) and "find expected load" (:26-28); (2) fixed 6-category priority order correct>safe>load>tested>fast>lean (:30-55); (3) "Every finding needs a concrete case... No case, no finding", re-read lines, no style taste (:57-67); (4) output: numbered, Must/Should/Nice groups, 4-part finding (What this is / Problem / Fix / If we skip it), Verdict, `Lean: -N lines`, `Not checked:` (:69-99). Audit adds map-first, "say which parts you did not read", <=20 findings with omitted count (audit SKILL.md:16-28, 83-86).
8. Subagent propagation hook: hooks/ponytail-subagent.js:1-12, 122-128: parent SessionStart context does not reach Task subagents, so a SubagentStart hook re-injects the ruleset; fail-open on any doubt (:149-181). Relevant to ticket-builder/ticket-reviewer, which only see their own prompt.
9. Codebase map injection: hooks/ponytail-map.js:1-10, 75-90; invoked at hooks/ponytail-activate.js:63-69 with 3 s timeout, 2000-char budget, fail-open.
10. Mode-filtered prompt: hooks/ponytail-instructions.js:11-41 drops table rows for inactive levels so the injected prompt carries only the active level.
11. Drift control for duplicated prompts: scripts/check-rule-copies.js:20-60 byte-compares 7 copies against AGENTS.md and pins load-bearing phrases (INVARIANTS) across SKILL.md and AGENTS.md.
12. Evidence discipline: CONTRIBUTING.md requires baseline / main / branch arms, >=6 runs, plus an existing task the change could break. benchmarks/agentic/ has hidden checks and injected-bug scoring. skills/ponytail-gain/SKILL.md:42-48 "Honesty boundary: NEVER print a per-repo savings number".
13. Reuse% metric: hooks/band/metrics.ts:292-294 (reused vs created functions, suppressed below 3).

## 4. Strong and weak points

Strong (ranked):
1. The review/audit output contract (review SKILL.md:57-99): "no case, no finding", fixed priority order, 4-part finding, Verdict / Not-checked footer. Tight and portable to ticket-reviewer; kills vague "consider" findings.
2. Scope-vs-laziness framing (SKILL.md:17-19, ~33): best anti-overbuild text; pairs "name what you skipped" with "never skip callers/tests".
3. "Read the connected code, not only the diff" + grep callers of changed signatures (review :21-29, 61-62). Their benchmark claims 100% vs 87% planted problems and 100% vs 78% outside-the-diff problems found.
4. Shortcut marker + debt ledger: cheap, greppable, makes deferrals auditable; reviewer-exempt-if-marked closes the loop.
5. Closing line "what you skipped / did not check / risk": forces honest reporting; matches multi-implement's "unmeasured assertions" bar.
6. SubagentStart injection insight (hooks/ponytail-subagent.js): a real gap in subagent-driven flows.
7. Eval culture (baseline vs variant, hidden checks, drift canary): the method is worth more than the prompt.

Weak / gimmicks:
- Most of the repo is multi-host packaging, marketing (star/trendshift badges, waitlist banners, sponsor), persona jokes, i18n READMEs. Irrelevant to Patrick.
- Band/board/webhook telemetry: large TSX surface, cost dashboards, past-session import, optional webhook. `ledger` defaults to true (per-turn CSV to ~/.config/ponytail; .claude-plugin/plugin.json). Not worth installing; privacy surface for no skill value.
- Always-on persona in every session and every subagent is a context tax and can fight domain conventions (PLC framework rules, glossary, "house component beats native"). Ultra "push back on the request" conflicts with spec-driven tickets where the bar is already agreed.
- Metrics are self-published, Bash disabled in the benchmark (measures what is written, not what is run/debugged), small-scope tasks. "-53% code" is a proxy that can reward under-building on real multi-file work. Reuse% is regex symbol counting.
- Minimalism bias is risky for PLC/industrial work: line count is not the objective; explicit, verbose ST is often the convention (framework-conventions). The never-cut list helps, but the "stdlib first" ladder is code-centric.
- Review skills are single-agent prompts: no fresh-context isolation, no builder/reviewer exchange, no ticket or bar concept. The plain-English-for-novice style (explain every term, 4 bullets per finding) is verbose for an expert reviewer.
- Test reflex ("one small test") is weaker than /tdd at seams.

## 6. Harvestable pieces

1. Finding gate, skills/ponytail-review/SKILL.md:59-60: "Every finding needs a concrete case: 'this input or situation leads to this wrong result'. No case, no finding." and :67 "No style taste, no 'consider', no vague worries."
2. Priority order, :12-13: "Order of importance: correct, safe, holds under load, tested, fast, lean."
3. Connected-code read, :21-25: "Read the diff, then the code it touches: callers of every changed function, the functions it calls, the tests, the README." and "A change can break code it does not touch. When a signature, return value or behavior changes, grep every caller."
4. Smell: "a fix applied in one caller while the shared function stays broken" (:32-34).
5. Output footer, :93-96 and :82-83: `Verdict: Ship.` / `Verdict: fix 1 and 3 first.`, `Not checked:` one line; findings numbered across groups "so the user can say 'fix 2 and 5'".
6. Marked-shortcut exemption, :63-64: "A shortcut marked with a `shortcut:` comment that names its limit is a decision, not a finding, unless the expected load already crosses it."
7. Builder scope rule, skills/ponytail/SKILL.md:17-19: "List every place your change must reach: callers, tests, fixtures, config, exports. Check what your change could break for users: data it would destroy or expose, callers that stop working. That is scope. Extra features are not."
8. Builder closing line, SKILL.md:15: "End your reply with one or two lines: what you skipped or did not check, and any risk the user must know."
9. Test trigger definition, SKILL.md:~41: "new non-trivial logic (a branch, a loop, a parser, money or security...) leaves one small test... Trivial changes need none."
10. Bug-fix rule, SKILL.md:~38-39: "before you edit, grep every caller of the function you touch, then fix the root cause once in the shared code." and "Code you move or merge keeps its error handling and validation."
11. Reuse ladder (adapted), :21-29, esp. rung 2 "Already in this codebase... Use it the way the surrounding code does."
12. Never-cut list, ~:44 (adapt: add PLC safety/interlocks, calibration, glossary terms).
13. Shortcut comment format + debt skill: SKILL.md:~42, skills/ponytail-debt/SKILL.md:18, 36-39.
14. Codebase-map idea: hooks/ponytail-map.js (exported symbols per dir inside a char budget); could feed the "exemplar" step of the bar.
15. Drift canary pattern: scripts/check-rule-copies.js INVARIANTS array (pin load-bearing phrases across copies).
16. Honesty boundary: skills/ponytail-gain/SKILL.md:44-48 (no invented baselines/savings).
17. Audit: "say which load you assumed" / "say which parts you did not read" (audit SKILL.md:22-23, 27-28).

## 7. Fit with multi-implement

- to-spec: ladder rung 1 ("does it need to exist? name what you skip in one line") as a single line in the seams step feeding "Out of Scope". Low value; the template already has the section.
- to-tickets: rungs 2-3 as a reuse check in step 2 ("Explore the codebase"): name an existing helper to reuse per ticket. Optional symbol map to speed exploration. Marginal.
- multi-implement step 1 (bar): add the "load assumed" line (#17) for tickets with scale implications; #16 honesty boundary duplicates the existing "every claim measured" paragraph, nothing to add.
- ticket-builder.md (currently a bare stub): best insertion point. Add #7 (scope = callers/tests/fixtures/config/exports), #10 (grep callers, fix once in shared code, keep validation on move), #9 (test trigger), #12 (never-cut incl. PLC safety), #13 (`shortcut:` marker with limit + trigger), #8 (closing "skipped / not checked / risk" lines). About 12 lines, no persona. The SubagentStart lesson also applies: builders only know what their prompt/agent file says, so put the rules in the agent file, not a session hook.
- ticket-reviewer.md (stub): second-best insertion. Add #1, #2, #3, #4, #6, #5. Numbered findings let the builder answer "1 fix, 2 contest (file:line), 3 escalate" in multi-implement step 3's four-way sort; map Must/Should/Nice onto fix-priority only. Drop the plain-English / 4-bullet style for an expert reader; keep What / Problem / Fix at most.
- multi-implement step 4 (Land): run a `/ponytail-debt`-style grep over the merged tree and list new `shortcut:` markers in the final report; cross-reference follow-up issues. One line.
- Separate skill candidate: `shortcut-debt` (port of ponytail-debt, ~40 lines, docs-knowledge). Review/audit: harvest the finding gate and footer into existing `code-review` / `review-function-block` rather than adding a new skill.
- Do not port: persona/levels, ponytail-gain/help, band/board/webhook, multi-host plumbing, SessionStart always-on injection, map hook (unless exploration tokens become a pain).

Note: some line numbers marked "~" are approximate (SKILL.md body lines 33-44 were read from a cat without -n; the skill is ~45 lines).
