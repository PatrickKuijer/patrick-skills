---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, merge-base or PR) along two axes — Standards (repo coding standards + a smell baseline) and Spec (does it do what the ticket/spec asked) — in two parallel fresh-context subagents, with a strict finding contract. Use when the user wants a branch, PR or work in progress reviewed, asks to 'review since X', or as the final gate of implement / multi-implement."
argument-hint: "<fixed point | PR url or number> [spec ref]"
---

## 1. Pin the fixed point

Use what the user gave (sha, branch, tag, `main`, PR). A PR: check out its
head (`gh pr checkout`, with `GH_HOST` for GitHub Enterprise) and use its base
as the fixed point. Nothing given: ask.

`git rev-parse <fixed-point>` must resolve and `git diff <fixed-point>...HEAD`
must be non-empty; fail here, not inside two subagents. Note the commit list
(`git log <fixed-point>..HEAD --oneline`).

A review ledger lives at `.local/reviews/<branch-or-pr>.md`. If it exists,
pass it on: findings already settled there are not re-raised, a fixed finding
that reappears is reopened.

## 2. Find the spec

In order: ids in commit messages or the PR body (fetched via
`docs/agents/workflow.md`), a path the user passed, a spec under `.local/`,
`docs/`, `specs/` matching the branch. None and the user confirms there is
none → the Spec axis is skipped and reported as "no spec available".

## 3. Find the standards

Every file that documents how code is written here: `CODING_STANDARDS.md`,
`CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, `docs/agents/workflow.md`. For
Structured Text add the `framework-conventions` skill; for user-facing text
the `glossary` skill. Repo standards override the smell baseline below.

## 4. Two subagents, in parallel, fresh context

Issue both calls together and wait for both. Shared contract in both briefs:

> Every finding needs a concrete case: "this input or situation leads to this
> wrong result". No case, no finding. No style taste, no "consider". Number
> findings across the report. Each: location, case, smallest fix. Order of
> importance: correct, safe, holds under load, tested, fast, lean. Read
> callers of every changed function, not only the hunks. A `shortcut:` comment
> naming its limit is a decision, not a finding. Skip what tooling enforces;
> treat lint/bot output as input to verify. End with `Not checked:` one line.
> Nothing found: say so and what you checked. Under 400 words.

**Standards** brief adds: the standards files, and the smell baseline pasted
in full (`references/smells.md`) — each smell a labelled judgement call
("possible Feature Envy"), never a hard violation. Cite the standard (file +
rule) for every hard violation.

**Spec** brief adds: the spec and ticket text, and three questions —
(a) asked for but missing or partial, (b) in the diff but not asked for,
(c) looks implemented but wrong. Quote the spec line for each. Plus one line
per acceptance criterion: PASS / FAIL / UNVERIFIED with evidence.

## 5. Report

Under `## Standards` and `## Spec`, the two reports lightly cleaned. Do not
merge or rerank across axes: code can follow every standard and build the
wrong thing, or build the right thing against the conventions; one axis must
not mask the other. End with the count per axis, the worst finding within
each, and `Verdict: Ship` or `Verdict: fix <numbers> first`.

Append the findings and their later outcome (fixed / contested / declined) to
the review ledger. Asked for a PR review: give it here in chat unless the user
asks for PR comments.
