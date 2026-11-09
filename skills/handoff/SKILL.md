---
name: handoff
description: "Save where this session stands to a handoff file so the next session continues without re-briefing, then say whether /clear is safe. Use when the user asks 'can I clear', 'safe to clear?', 'write a handoff', 'record this so I can clear', when a long run is about to hit limits, or at the end of implement / multi-implement / decide. Also resumes: 'continue', 'resume', or a handoff path loads the latest handoff."
argument-hint: "What will the next session be used for? (or: resume)"
---

The user keeps one long terminal per repo and clears between tasks. Context
that only lives in this conversation is lost on `/clear`. This skill moves it
into a file first.

## Write

1. **Where.** In a git repo: `.local/handoffs/<YYYY-MM-DD-HHmm>-<slug>.md`, and
   make sure `.local/` is listed in `.git/info/exclude`. Outside a repo: `%TEMP%`.
2. **Check before claiming safe.** Run `git status --short` and
   `git branch --show-current`. If the current branch is already merged or
   deleted upstream, or uncommitted work sits on a branch another session
   owns, say so at the top of the file and in chat.
3. **Content.** Pointers, not copies: name specs, tickets, ADRs, commits, PRs,
   branches, worktrees by path, id or URL. Write only what is not already in
   one of those artifacts.

```markdown
# Handoff: <slug>  (<date time>, branch <name>, HEAD <short sha>)

## Goal
<one or two sentences: what this thread is trying to achieve>

## Done
- <outcome> → <pointer>

## In flight
- <what is half-done, where it lives, what state it is in>

## Next
1. <first concrete step for the next session>

## Waiting on a human
- <HITL step, who, exact action>   (omit if none)

## Decisions and why
- <decision> — <reason>   (only decisions not yet in an ADR/ticket)

## Learned the hard way
- <fact a fresh agent would otherwise rediscover; command that fails + the one that works>

## Suggested skills
- <skill> for <step>
```

4. **Redact** secrets, tokens, tenant/subscription ids and personal data.
5. **Close in chat** with exactly:
   - `Safe to /clear: yes` — or `no: <what would be lost>` (uncommitted
     work not described in the file, a running background job, an
     unanswered question).
   - A paste-ready first prompt: `continue from .local/handoffs/<file>`.

If the user passed an argument, tailor **Next** and **Suggested skills** to it.

## Resume

On `resume`, `continue`, or a handoff path: read the named file, or the newest
in `.local/handoffs/`. Then check it against reality before acting — `git log`
since its HEAD, ticket states, whether **Waiting on a human** items are done.
Report the differences in one short list, then continue with **Next**.
Never redo an external action the file records as done (a push, a deploy, a
ticket close); confirm its state instead.
