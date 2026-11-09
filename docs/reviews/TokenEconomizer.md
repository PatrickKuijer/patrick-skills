# Review: microsoft/TokenEconomizer (latest main, commit 264e7a7, 2026-11-08)

Repo path: <clone>/microsoft_TokenEconomizer
(All path:line cites below are relative to that root. README line numbers are the physical lines of README.md.)

## 1. What it is

NOT a skill/prompt collection. It is a research-grade, stdlib-only Python package (~18k lines in `tokeneconomizer/`, plus `experiments/`, 100+ test files) shipped as a hook-driven plugin for Claude Code, Codex, Copilot CLI, Pi (experimental: opencode, Cursor, Grok, Hermes, Antigravity). It accompanies a paper (arXiv 2610.22732, UC Berkeley + Microsoft Research; README.md:1-26). It "reads finished sessions and changes what later sessions in the same repository pay for" (CLAUDE.md:3-4) through three mechanisms (README.md:47-69): (1) micro-skills = learned repo facts injected at SessionStart, (2) tool pruning = deny-listing tools never used in this repo, (3) a loop guard = detects a turn stuck in a failing loop, judge model confirms, injects one redirect. It does NOT compress model output or prompts (unlike caveman). Only `plugin/` is installable; `experiments/` is the benchmark harness.

Maturity: high engineering rigor (fail-open hooks, locks, per-host verified behavior notes with versions/dates in docs/PLUGIN.md:100-364, offline tests, a dead-code CI sweep), but single squashed-history repo (git log = 1 commit visible), version 0.1.0 (plugin/.claude-plugin/plugin.json). Pinned to Claude Code 2.1.300-2.1.310 (README.md:264); readers parse internal transcript formats that "change between versions" (docs/PLUGIN.md:834-835). Windows: Claude Code path is handled (plugin/scripts/te-hook:4-36 has Git-Bash/WindowsApps Python handling) but Cursor/agy are POSIX-only and "Windows beyond Claude Code ... untested" (docs/PLUGIN.md:826-827). Needs Python 3.10+ on PATH.

License: **Apache License 2.0** (LICENSE, standard unmodified text, "Version 2.0, January 2004"; appendix at LICENSE:179-190 still has the `[yyyy] [name of copyright owner]` placeholder, no actual copyright line in the file; plugin.json says "Apache-2.0"). Allows: copy, modify, redistribute, commercial/private use, with patent grant. Obligations for copying code/text: keep the license text, keep copyright/attribution notices, state changes in modified files, carry any NOTICE (none exists). Short quoted text snippets for a personal skillset are fine; if verbatim code files are vendored, add attribution + license. Nothing here blocks adapting prompts/structures.

## 2. Inventory

There are no SKILL.md in the Claude plugin, no agents, and no subagent definitions. The "skills/commands" are thin wrappers that run one shell command and print its output.

Slash commands (plugin/slash-commands/*.md, Claude Code + Copilot): each runs `te --cwd "$(pwd)" <cmd>` via Bash and echoes the output verbatim.
- `status.md` - show what it learned/did and session costs.
- `microskills.md` (+ `facts.md` alias) - show injected facts and forming ones.
- `toolprune.md` (+ `untool.md` alias) - show/apply/restore deny list, refresh-catalog, measure.
- `config.md` - show/set settings.
- `repos.md` - list/migrate/merge per-repo state.
Codex equivalents: plugin/codex-skills/{config,microskills,repos,status,toolprune}/SKILL.md (same wrapper pattern, e.g. codex-skills/microskills/SKILL.md).

Hooks (plugin/hooks/hooks.json for Claude; copilot-hooks.json, codex-hooks.json, cursor-hooks.json): SessionStart (15s), UserPromptSubmit (20s), PostToolUse (60s), PostToolUseFailure (60s), Stop (10s), SessionEnd (10s), all -> `plugin/scripts/te-hook` -> `te_bootstrap.py hook` -> `tokeneconomizer/plugin/hook.py` dispatcher. Every hook fails open (docs/PLUGIN.md:71-72).

Scripts: `plugin/scripts/te` (CLI launcher), `te-hook` (POSIX sh launcher), `te_bootstrap.py`, `scripts/build_plugin.py` (builds self-contained bundle), `scripts/dead_code.py`.

Core package modules (all Python):
- `tokeneconomizer/microskills/` - `observe.py` (classify shell commands by intent/form/outcome), `envfacts.py` (5 LLM-free fact families), `distiller.py` (paid LLM proposer + detector DSL), `lifecycle.py` (promote/retire), `stage.py`.
- `tokeneconomizer/toolprune/` - `stage.py` (evidence streaks), `codex.py` (Codex capability packages), `tools.py` (protected sets).
- `tokeneconomizer/loopguard/` - `turn.py`, `rules.py` (thresholds, gate, nudge text), `judge.py` (judge + nudge-writer prompts), `envelope.py`, `state.py`, `shell_edits.py`.
- `tokeneconomizer/trace/` - one session-log reader per agent (claude.py, codex.py, copilot.py, pi.py, cursor.py ...).
- `tokeneconomizer/plugin/` - runtime: `hook.py`, `hosts.py` (per-agent adapters), `sidecall.py` (how it calls `claude -p` etc.), `denylist.py` (writes `.claude/settings.local.json`), `fold.py`, `history.py` (import old Claude sessions), `repomap.py`/`repomap_gen.py` (opt-in aider repo map), `toolcheck.py`, `cli.py`, `store.py`, `hookqueue.py`.
- `tokeneconomizer/pricing.py`, `ledger.py`, `plugin/accounting.py` - cache-aware cost ledger.
- Non-Claude bridges: plugin/pi/tokeneconomizer.ts, plugin/opencode/tokeneconomizer.ts, plugin/hermes/.
- `experiments/` - benchmark harness (te_harness/, te_bench/: arms, baselines rtk/repomap/serena, answer-key guard, codex_spiral.py), 4 workload id lists, aggregation scripts. Not shipped in plugin.
- docs/: ARCHITECTURE.md (37 lines), PLUGIN.md (835 lines; design + verified per-agent hook behavior), asset generators.
- CI: .github/workflows/{tests,dead-code-sweep,submission-limit}.yml.

## 3. Core mechanisms

### 3a. Measured savings (numbers) vs claimed

MEASURED (by the authors, in the paper; NOT reproducible from this repo alone):
- Headline: SWE-Bench, 277 tasks / 6 repos, 5 agent-model combos: mean cost 18.4-30.9% lower, cheaper in 30/30 repo x combo cells, Pass@1 up in 4 of 5 (README.md:35-37, 82-86). Per-combo table lives only in `docs/assets/results_overview.py:31-37`:
  Claude Code+Sonnet 5: -23.6% cost (sd 1.8), Pass@1 74.7 -> 76.0
  Claude Code+Opus 4.8: -30.9% (sd 2.1), Pass@1 74.0 -> **73.0** (the one quality drop)
  Codex+GPT-5.6 Terra: -24.7% (1.2), 73.8 -> 74.7
  Codex+GPT-5.6 Sol: -26.1% (2.1), 80.1 -> 81.7
  Copilot CLI+Sonnet 5: -18.4% (1.5), 75.0 -> 77.6
  Docstring states "The numbers are the paper's ... nothing here is computed from runs in this repository" (results_overview.py:13-15). No raw rows/CSVs are committed (searched; only workload id lists in experiments/workloads/). So I could verify the numbers only as stated, not recompute them.
- Web-Bench: 16-21% lower; two security benchmarks 6-20% lower (README.md:85-86).
- Cost basis is honest: cache-aware "effective tokens" with per-model price ratios (input 1.0, cache_read 0.10, cache_write 1.25, output 5.0 for Claude; tokeneconomizer/pricing.py:1-60), and includes the plugin's own judge/proposer calls (README.md:83-84; plugin/judge.py:313-315 charges ledger when spent). The experiment run learns from zero, in sequence per repo (README.md:83-84), i.e. savings accrue only after sessions accumulate.
- Mechanism-level numbers in the shipped docs: Claude Code was "live sessions counted 39 of 47 calls" before PostToolUseFailure was registered (docs/PLUGIN.md:124-128: bug fix, not a saving). Micro-skills: "In the experiments the free layer alone formed almost nothing once the harness set each environment up properly, so `on` keeps the proposer" (docs/PLUGIN.md:97) - i.e. the LLM-free layer is weak.
- Per-mechanism ablation (inject-only/untool-only/spiral-only) exists as experiment arms (experiments/README.md:112,120) but results not included in repo.

CLAIMED / unmeasured in real use:
- Plugin (interactive, real sessions) savings are NOT measured: "both rungs have run on a provoked loop on every agent (2026-10-21), not on a real spiral, and whether a nudge changes a looping model's course is not established (on Pi one run stopped after it, another went on)" (docs/PLUGIN.md:766-771). The benchmark redirect = kill + resume; the plugin redirect is a mid-turn additionalContext, "a different intervention, so its effect is not inherited from the experiments" (docs/PLUGIN.md:94).
- Micro-skills is OFF by default because "how much it saves depends on the repository" (README.md:336-337 area, "Settings").
- Verified that injected facts reach the model (end-to-end: bare `pytest` missing -> model answers use `python -m pytest`, docs/PLUGIN.md:107-110) - a mechanism check, not a savings measure.

### 3b. Techniques (with citations)

1. **Cross-session experience, not per-prompt compression.** Facts from finished sessions injected via SessionStart `additionalContext` (docs/PLUGIN.md:16; hooks.json SessionStart). Promotion: 3 confirming sessions (`microskills/lifecycle.py:15` K_PROMOTE=3), retire on contradiction (LAMBDA=5.0, line 17), only inject while the failure it prevents actually fires in >=40% of >=4 exercising sessions (lifecycle.py:20-21 FIRE_GATE/FIRE_MIN_N). Hard cap: 4 facts / 150 tokens including header (`microskills/envfacts.py:49-50`). Block format: `# environment facts learned from earlier sessions in this repository` + `- ` bullets (envfacts.py:51-53,281).
2. **Fact lint: no completion/verification advice.** `_LINT_RE` rejects facts containing skip/no need/don't/do not/stop/done/complete/finish/verify/instead of running (envfacts.py:55-57, used at 301). Principle: injected priors must not be able to shorten verification.
3. **Proposer prompt rules** (distiller.py ~L421-478): facts must be declarative; "NEVER phrase it as a prohibition on exploration or tool use ... A prior that suppresses exploration silently breaks later tasks"; each fact needs a host-run regex detector + >=2 citations; "a fact you cannot ground with a working detector + 2 citations is worse than no fact." Facts about WHERE things are / canonical commands, never task-specific fixes.
4. **Tool pruning by evidence, reversible.** Tool unused over 10 prompts across >=2 sessions or 5 sessions -> added to `.claude/settings.local.json` deny list (README.md:60-63; docs/ARCHITECTURE.md:113-121). Protected: work surface + AskUserQuestion, plan mode, Agent/Task, Skill, ToolSearch, Monitor, WebFetch/WebSearch, TodoWrite (`plugin/adapter.py:36-48`); NotebookEdit needs 3x evidence (adapter.py:60-61). Written only after repo idle `toolprune_quiet_minutes`=60 because changing tools mid-conversation invalidates the prompt cache (README.md settings text; docs/PLUGIN.md:90). `restore` removes exactly its own entries and tools given back are never re-removed (README.md:79-86). Verified mechanism: bare-name `permissions.deny` removes the tool from the session list, equal to `--disallowed-tools` (docs/PLUGIN.md:115-119).
5. **Loop guard = free gate -> judge -> single redirect.** Per tool call, fold into `SpiralState` (edit churn per file, distinct files, error outputs, repeated failure signatures, verification runs; also edits made through the shell: sed -i, tee, inline python, apply_patch; docs/PLUGIN.md:30-34). Free gate opens only after >=18 calls and (a repeated identical failure OR >=8 error outputs) (`loopguard/rules.py:41-42, 78-90`); strict heuristic = churn(>=4 edits/file or >=3 files) AND >=6 errors AND >=20% repeated failures (rules.py:20-26, 93-106). Judge only when gate open; defaults: confidence >=0.7, 1 redirect per turn, hard backstop at 2.5x per-repo "envelope" (p90 of turn length of turns that ended well; `envelope.py`) that the judge cannot veto (rules.py:128-144). Never stops a turn; after a failed redirect only tells the user "Press Esc" (README.md:90-125; docs/PLUGIN.md:95).
6. **Judge on a cheap side call, off the hot path.** `claude -p --output-format json --tools "" --max-turns 1 --model haiku` + no MCP + `--no-session-persistence` (`plugin/sidecall.py:8-10, 279-284`); judged by a detached `te judge` job so the hook never waits (plugin/judge.py:1-12, 325-350). Digest sent is "leakage-safe": command templates, edited file basenames, masked error signatures, never file contents or the task text (loopguard/state.py:218-236).
7. **Redirect text mirrors the agent's own actions, never tells it to stop** (rules.py:183-198):
   "Process check (automated): so far you've made N edits across M file(s) ... This looks like a repetitive loop. Do NOT stop - instead step back and try a MATERIALLY DIFFERENT hypothesis: re-read the failing test's expectation, consider a different file or root cause ..., and verify the new hypothesis directly before editing again."
8. **Judge system prompt biases toward sparing** (loopguard/judge.py:213-225): "Favor SPARING (stuck=false) when there is any sign of progress; only return stuck=true with high confidence for a clear, repetitive dead-end." Judge sees only the workflow, "do NOT infer the task's solution".
9. **Cost accounting as a first-class invariant**: one ledger/pricing definition shared by plugin and experiments so "recorded and reported cost cannot drift" (docs/ARCHITECTURE.md:10-13); hard-fail on unknown model id rather than mis-price (pricing.py:25-27).
10. **Failure containment**: all hooks fail open; per-session hook queue/lock (docs/PLUGIN.md:74-81); state private 0700/0600 (docs/PLUGIN.md:689+ "State and privacy"); deny writer refuses symlinks leaving the repo and unparseable settings files.
11. **Opt-in repo map** (`repomap=on`, aider PageRank map as a fixed prefix; plugin/repomap.py:1-30), noted by the authors as "a cost on sessions that already knew where to look, a saving on those that would have searched" (repomap.py:28-29). It is an experiment baseline, not one of the three headline mechanisms.

## 4. Strong / weak points

Strong (ranked):
1. **Honest cost methodology.** Cache-aware effective tokens, includes own overhead, paired per-task comparison, answer-key guard on every arm, and Pass@1 reported alongside cost incl. the Opus -1.0 drop. Rare in this space; the right way to judge any token-saving skill. (pricing.py:1-60; experiments/README.md:151-152,168-170)
2. **Safety-first design rules for injected context**: facts must be evidence-grounded, capped, reversible, linted against "skip/verify" advice, and never forbid exploration. Directly transferable discipline.
3. **Gating cascade (free rules -> cheap model -> rare action) with a non-vetoable backstop** - keeps the monitor from being a per-step tax. (rules.py:1-14, 109-180)
4. **Redirect not abort; mirror the agent's own actions; "Do NOT stop".** Good wording for a mid-run nudge.
5. **Per-host verified-behavior documentation** with versions/dates (docs/PLUGIN.md:100+): real facts, e.g. a failed Bash call fires `PostToolUseFailure` not `PostToolUse`; Bash `tool_response` has no exit code; plugin `settings.json` cannot carry deny rules; hook output channels; `claude -p` hooks see `CLAUDE_CODE_SESSION_ATTENDED=0` (docs/PLUGIN.md:105-136). Useful reference if Patrick ever writes his own hooks.
6. Tool-pruning idea is sound: tool schemas are resent every request, and cache-timing handling (wait for idle) shows real understanding.

Weak / gimmick / would not survive:
1. **Mostly irrelevant to Patrick's actual token sinks.** It optimizes many repeated sessions in ONE repo with a shared command surface. Blueprint PLC work (TwinCAT/CoDeSys, ST function blocks, Jira/Confluence) is varied; Claude Code's own tool list is already small and deferred-tool search already hides most MCP tools. Likely savings for him: small. It also needs >=3 sessions per fact, >=5 to start the guard envelope (`envelope_min_samples`=5), so nothing happens for the first sessions.
2. **Python/POSIX-hook plugin with heavy install surface**: pinned to CC 2.1.300-2.1.310, reads internal transcript formats, writes `.claude/settings.local.json`, detached background processes on every SessionEnd, state in `~/.tokeneconomizer`. Fragile for a personal skillset; cannot be "ported" as markdown.
3. **Loop guard effect unproven live** (docs/PLUGIN.md:766-771); the rule counts edits and repeated failures "not understanding" and could fire on a turn that already found its cause; "a turn that ran no recognised verification counts as ended green" and "test runs launched from a script are not recognised" (docs/PLUGIN.md:817-822). Recognises pytest/tox-style test commands, not TwinCAT/PLC build flows.
4. **Micro-skills' LLM-free layer "formed almost nothing"** (docs/PLUGIN.md:97); the paid proposer is off by default; facts derived from command output a repo controls = prompt-injection surface (docs/PLUGIN.md:752-757, authors flag it themselves).
5. Headline numbers are benchmark (sealed SWE-Bench in Docker, runs in sequence, with an injected learning-from-zero stream), not interactive human-in-the-loop sessions; plugin docs concede the redirect differs from the benchmarked intervention (docs/PLUGIN.md:94). Opus: Pass@1 -1.0.
6. Docs claim to "never stop a turn" so the guard cannot save the worst runaway cost; only a human Esc does. In headless runs "a flagged turn runs until it ends" (README.md:124-125).
7. Hermes hits a security scanner finding on `rm -rf ~/.tokeneconomizer` in plugin/README.md (docs/PLUGIN.md:~395) - minor, but shows install-time friction.
8. Slash commands burn one model turn each ("Inside an agent, a command costs one model turn; from a terminal it is free", README.md:328).

## 5. Category tags

| Item | Tag |
|---|---|
| microskills (observe/envfacts/distiller/lifecycle), SessionStart injection | context-token-economy |
| toolprune (+ denylist.py, tools.py, codex.py) | context-token-economy |
| loopguard (rules/judge/state/envelope/turn) | debugging (stuck-loop detection) + context-token-economy |
| repomap.py / repomap_gen.py | context-token-economy |
| pricing.py / ledger.py / accounting.py (effective-token cost) | context-token-economy |
| trace/* session-log readers | context-token-economy |
| slash-commands/status, microskills, toolprune, config, repos (+aliases facts, untool) | context-token-economy |
| codex-skills/* (5 wrappers) | context-token-economy |
| hooks/*.json, te-hook, te_bootstrap.py, hook.py, hookqueue.py, hosts.py | skill-authoring-meta (hook plumbing) |
| docs/PLUGIN.md "Verified agent behaviour" | docs-knowledge (also skill-authoring-meta) |
| experiments/ (harness, baselines, arms, answer-key guard, aggregate/compare scripts) | review-qa (eval methodology) |
| sidecall.py (headless `claude -p` helper calls) | orchestration-implement (subagent-style side calls), skill-authoring-meta |
| CLAUDE.md, ARCHITECTURE.md | docs-knowledge |
| plan-spec, communication-style | none present |

## 6. Harvestable pieces

(Everything below is text/structure ideas; the Python machinery is not worth porting.)

A. **Mid-run "process check" redirect wording** - rules.py:189-198: "Process check (automated): ... This looks like a repetitive loop. Do NOT stop - instead step back and try a MATERIALLY DIFFERENT hypothesis: re-read the failing test's expectation, consider a different file or root cause than the ones you've been editing, and verify the new hypothesis directly before editing again."

B. **Loop-detection signature (conjunction, so hard-but-productive tasks are spared)** - rules.py:15-26: churn (>=4 edits to one file OR >=3 files) AND sustained errors (>=6) AND repeats (>=20% of failures repeat an earlier one); don't judge before ~20 tool calls; calibrated "first-40-turn edit_churn ~6 vs ~1.5 normal, error_outputs ~9 vs ~3". Usable as a plain-language "stuck" checklist for builders/orchestrator.

C. **Judge instruction: favor sparing; judge workflow only, not solution** - loopguard/judge.py:219-222: "Favor SPARING (stuck=false) when there is any sign of progress; only return stuck=true with high confidence for a clear, repetitive dead-end." And "Judge ONLY the workflow from the digest; do NOT infer the task's solution".

D. **Nudge-writer hard constraints** - judge.py:274-277: "Do NOT tell it to stop, give up, or reduce effort - only redirect. Do NOT infer the task's solution, name specific line numbers to change, or reference any code/identifier you cannot see in the digest." (Also: "names the specific repetitive pattern you actually see" + "proposes a MATERIALLY DIFFERENT next step".)

E. **Rules for what may be injected as a durable repo fact** - distiller.py ~L428-436 & 460: declarative only; "NEVER phrase it as a prohibition on exploration or tool use"; "only durable interface facts true across tasks" (canonical test/build command, required env var, needed/not-needed build step, formatter that rewrites files, command that fails here + variant that works); "a fact you cannot ground with a working detector + 2 citations is worse than no fact".

F. **Fact-block shape and caps** - envfacts.py:49-53: header line + <=4 one-line bullets, <=150 tokens; and lint list envfacts.py:55-57 (refuse skip/no need/don't/stop/done/verify/...). Good template for a "repo facts" file that builders get.

G. **Claim templates (very concrete, token-cheap)** - envfacts.py:100-105: "`<form>` fails here with <ModuleNotFoundError/command not found>; `<working form>` works." / "Outbound connections to <hosts> are refused here; nothing can be fetched from them." Also: show a `cd DIR && cmd` form as a subshell `(cd DIR && cmd)` because Claude Code keeps cwd between calls (envfacts.py:213-216).

H. **Side-call recipe for cheap helper model** - sidecall.py:8-10,283-284: `claude -p --output-format json --tools "" --max-turns 1 --model haiku` with no MCP and `--no-session-persistence` for pure-text one-shot judgement.

I. **Leakage-safe digest for a reviewer/judge** - state.py:218-236: head line of counters (turns, edit_churn, distinct_edit_files, error_outputs, test_runs, repeated_identical_failures, stagnation) + last 24 actions (commands, searched patterns, edited basenames, error signatures), never contents. Same idea as "give the reviewer the artifact, not the builder's account".

J. **Cost-measurement discipline for evaluating skills** - pricing.py:1-25, experiments/README.md:168-170: weight tokens by price (cache_read 0.10, cache_write 1.25, output 5x input), count helper-agent overhead, pair tasks, never pool runs across agent/model ("the agent and the model are both part of the cost basis"), and always report pass-rate next to cost.

K. **Principles list** - README.md:103-112: work through what the agent already reads; count cost as billed; protect task success (evidence first, leave alone a turn that is making progress); keep every action reversible.

L. **Verified Claude Code hook facts** (docs/PLUGIN.md:105-136) for any future hooks: PostToolUse `additionalContext` is followed in the same turn; `PostToolUseFailure` is a separate event for failed calls; Bash tool_response has no exit code; plugin settings.json cannot carry deny rules; SessionStart additionalContext reaches the model.

## 7. Fit with multi-implement (and overlap with caveman)

Patrick's flow: spec -> tickets -> `/multi-implement` (bar per ticket, slice into parallel/sequential, builder+reviewer pair, one SendMessage exchange, land with full suite, follow-up issues). Agents `ticket-builder` / `ticket-reviewer` are bare ("complete the task fully ... report back") so the brief carries everything.

Where each piece plugs in:

1. **Builder brief: stuck-loop tripwire (A+B+K)** -> add 3-4 lines to the step-3 builder dispatch or into `agents/ticket-builder.md`: "If the same failing check has recurred 3 times with edits to the same file, stop editing; restate the failing expectation, name a different root-cause hypothesis, verify it directly before the next edit; if still red after that, stop and report as not-green." This fits the existing "stops at green tests ... not another round" budget and gives the orchestrator a defined 'could not bring to green' trigger for the follow-up issue (step 4). Tailor the test recognition to his stack (TwinCAT build/library check, not pytest).
2. **Orchestrator watch-dog during parallel fan-out (B, C, D, I)**: the orchestrator cannot see inside running builders; a builder that returns after burning many turns is the observable. Add to step 3 report format: builder reports counts (edit count, files touched, number of test runs, number of times the same failure repeated). The orchestrator (or reviewer) flags "churn + repeated failure" tickets as landed-with-issue rather than re-dispatching. The leakage-safe digest (I) doubles as the format for the builder->reviewer handoff: counters + file list + failing check signatures, no narrative.
3. **Reviewer brief (C, I)**: reviewer already gets only the artifact. Borrow the judge phrasing "judge only the workflow/artifact against the bar; do NOT infer the solution" and the asymmetric-confidence rule ("only return a blocking finding with high confidence; any sign the bar is met -> pass"), and a JSON/one-line-per-finding output with confidence field so the builder's fix/contest/escalate/decline sort has a priority signal.
4. **Context handoff between orchestrator and builders (E, F, G, K)**: add an optional per-repo "repo facts" block (<=4 bullets, <=150 tokens, declarative, no "skip/don't/verify" advice, no prohibitions on searching) that the orchestrator prepends to every builder/reviewer brief: canonical test/build command, working vs failing command variants, env vars, generated-file locations. This is the manual, zero-infrastructure version of micro-skills and addresses "every builder re-discovers the same commands" (and the stated concern about the `tsc --build` worktree issue in multi-implement step 2). Keep the file in repo (e.g. docs/agent-facts.md) or CONTEXT.md; refresh it from builders' "what I had to figure out" lines at land time, but only keep a fact once 2-3 tickets confirmed it (their 3-confirmations rule).
5. **Land step (J)**: if Patrick ever wants to evaluate multi-implement variants (e.g. medium vs high effort builders) use their method: compare cost with cache-aware weights, include reviewer/orchestrator overhead, always report pass rate next to cost. Could be a small separate skill `skill-eval-cost` or a section in skill-authoring notes.
6. **Separate skill candidates** (not multi-implement): (a) `agent-facts` / repo operating facts (E,F,G; a writer that distils facts from a finished session into <=4 lint-clean bullets); (b) `stuck-check` (A-D) - a short skill the builder can invoke on itself when a red check repeats; (c) `cheap-judge` recipe (H) for a haiku one-shot `claude -p --tools ""` yes/no gate, only if Patrick wants scripted gating; not needed for normal flow.
7. **Not worth porting**: the Python plugin, hooks, tool pruning, ledger, trace readers, history import, repomap. Tool pruning is the only auto-applied part and it overlaps with Claude Code's deferred tool loading and Patrick's own permission settings; installing it would add a background process and rewrite `.claude/settings.local.json`.

Overlap/conflict with caveman:
- Different axis. Caveman = output/input text compression (style rules in caveman/SKILL.md; caveman-compress shrinks CLAUDE.md; cavecrew makes subagent results ~1/3 size so main context lasts; caveman-learn measures token sinks and applies edits with consent; caveman-stats). TokenEconomizer = never touches wording; it reduces repeated discovery (facts), schema overhead (tool pruning) and runaway loops (guard), learned automatically from logs.
- Complementary, not conflicting: caveman keeps each exchange short; TokenEconomizer targets repeated-session waste. The authors' own principle that injected text must be capped and must never say skip/verify matches caveman-learn's "never claim a saving you have not measured, never make the agent dumber".
- Genuine overlap: (1) token-sink measurement (caveman-learn/caveman-stats vs TE ledger) - TE's pricing weights and "include overhead" rule are a better basis than raw token counts; (2) "offload re-pasted context" (caveman-learn/cavemem) vs micro-skills' fact injection; (3) trimming heavy CLAUDE.md vs TE's 150-token fact cap.
- Possible conflict if both installed: TE injects SessionStart additionalContext and may rewrite tool permissions; a caveman-style "no preamble" rule would also shorten TE's loop-guard "repeat this line" request (on Claude Code the notice only shows because the model repeats it, README.md:114-116). Both can run, but TE adds hook latency and a Python dependency; Patrick's caveman skills are plain markdown.
- Recommendation: do not install TokenEconomizer for Patrick's workflow; harvest A-L above as text in multi-implement briefs / one small facts skill. Pair with caveman style only for the builder->orchestrator report ("path:line, counts, not prose") which cavecrew already formalizes.
