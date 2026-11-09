"""Condense Claude Code session transcripts (last N days) into small markdown digests.

usage: python -I digest_sessions.py <projects_dir> <out_dir> <since YYYY-MM-DD>
"""
import json, os, re, sys, collections, datetime

projects, out, since = sys.argv[1], sys.argv[2], sys.argv[3]
since_ts = datetime.datetime.fromisoformat(since).timestamp()
os.makedirs(os.path.join(out, "digests"), exist_ok=True)

SR = re.compile(r"<system-reminder>.*?</system-reminder>", re.S)
CMD = re.compile(r"<command-name>\s*/?([^<\s]+)\s*</command-name>")
ARGS = re.compile(r"<command-args>(.*?)</command-args>", re.S)
TAGS = re.compile(r"<(local-command-stdout|local-command-caveat|command-message|command-name|command-args)>.*?</\1>", re.S)


def trunc(s, n):
    s = re.sub(r"\s+", " ", s).strip()
    return s if len(s) <= n else s[: n - 1] + "…"


def user_text(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in c):
            return None
        return "\n".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text")
    return None


index = []
for proj in sorted(os.listdir(projects)):
    pdir = os.path.join(projects, proj)
    if not os.path.isdir(pdir):
        continue
    for fn in os.listdir(pdir):
        if not fn.endswith(".jsonl"):
            continue
        path = os.path.join(pdir, fn)
        if os.path.getmtime(path) < since_ts:
            continue
        sid = fn[:-6]
        sub_dir = os.path.join(pdir, sid, "subagents")
        n_sub = len([f for f in os.listdir(sub_dir) if f.endswith(".jsonl")]) if os.path.isdir(sub_dir) else 0
        title, cwd, branch, entry = None, None, None, None
        ts = []
        prompts, cmds, skills, agents, tools, bash = [], collections.Counter(), collections.Counter(), collections.Counter(), collections.Counter(), collections.Counter()
        models = collections.Counter()
        interrupts = errors = n_assist = 0
        last_text = ""
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                t = d.get("type")
                if t == "custom-title":
                    title = d.get("customTitle")
                if d.get("timestamp"):
                    ts.append(d["timestamp"])
                cwd = cwd or d.get("cwd")
                branch = branch or d.get("gitBranch")
                entry = entry or d.get("entrypoint")
                if d.get("isSidechain"):
                    continue
                m = d.get("message") if isinstance(d.get("message"), dict) else {}
                if t == "user":
                    c = m.get("content")
                    if isinstance(c, list):
                        errors += sum(1 for b in c if isinstance(b, dict) and b.get("type") == "tool_result" and b.get("is_error"))
                    if d.get("isMeta"):
                        continue
                    txt = user_text(m)
                    if not txt:
                        continue
                    if "[Request interrupted by user" in txt:
                        interrupts += 1
                        continue
                    cm = CMD.search(txt)
                    if cm:
                        cmds[cm.group(1)] += 1
                        a = ARGS.search(txt)
                        txt = f"/{cm.group(1)} {a.group(1) if a else ''}"
                    txt = TAGS.sub("", SR.sub("", txt)).strip()
                    if txt:
                        prompts.append(trunc(txt, 450))
                elif t == "assistant":
                    n_assist += 1
                    if m.get("model"):
                        models[m["model"]] += 1
                    for b in m.get("content") or []:
                        if not isinstance(b, dict):
                            continue
                        if b.get("type") == "tool_use":
                            name = b.get("name", "?")
                            inp = b.get("input") or {}
                            tools[name] += 1
                            if name == "Skill":
                                skills[inp.get("skill", "?")] += 1
                            elif name in ("Agent", "Task"):
                                agents[inp.get("subagent_type") or "general"] += 1
                            elif name in ("Bash", "PowerShell"):
                                w = (inp.get("command") or "").strip().split()
                                if w:
                                    bash[w[0][:20]] += 1
                        elif b.get("type") == "text" and b.get("text", "").strip():
                            last_text = b["text"]
        if not prompts and n_assist == 0:
            continue
        ts.sort()
        start, end = (ts[0], ts[-1]) if ts else ("?", "?")
        try:
            dur = (datetime.datetime.fromisoformat(end.replace("Z", "+00:00")) - datetime.datetime.fromisoformat(start.replace("Z", "+00:00"))).total_seconds() / 60
        except Exception:
            dur = 0
        shown = prompts if len(prompts) <= 30 else prompts[:18] + [f"… ({len(prompts) - 28} prompts omitted) …"] + prompts[-10:]
        name = f"{proj[:60]}__{sid[:8]}.md"
        top = lambda c, n=12: ", ".join(f"{k}×{v}" for k, v in c.most_common(n)) or "-"
        with open(os.path.join(out, "digests", name), "w", encoding="utf-8") as o:
            o.write(f"# {title or '(untitled)'}\n\n")
            o.write(f"- project: {proj}\n- cwd: {cwd}\n- branch: {branch}\n- entrypoint: {entry}\n- start: {start}  end: {end}  span_min: {dur:.0f}\n")
            o.write(f"- user_prompts: {len(prompts)}  assistant_msgs: {n_assist}  interrupts: {interrupts}  tool_errors: {errors}  subagent_transcripts: {n_sub}\n")
            o.write(f"- models: {top(models, 3)}\n- slash_commands: {top(cmds)}\n- skills_invoked: {top(skills)}\n- agents_spawned: {top(agents)}\n- tools: {top(tools, 15)}\n- shell_first_words: {top(bash, 10)}\n\n")
            o.write("## User prompts (in order)\n\n")
            for i, p in enumerate(shown, 1):
                o.write(f"{i}. {p}\n")
            o.write(f"\n## Last assistant text\n\n{trunc(last_text, 600)}\n")
        index.append([name, proj, title or "", start[:16], f"{dur:.0f}", str(len(prompts)), str(interrupts), top(cmds, 5), top(skills, 5), trunc(prompts[0] if prompts else "", 140)])

index.sort(key=lambda r: r[3])
with open(os.path.join(out, "index.tsv"), "w", encoding="utf-8") as o:
    o.write("digest\tproject\ttitle\tstart\tspan_min\tprompts\tinterrupts\tslash_cmds\tskills\tfirst_prompt\n")
    for r in index:
        o.write("\t".join(x.replace("\t", " ") for x in r) + "\n")
print(len(index), "sessions digested")
