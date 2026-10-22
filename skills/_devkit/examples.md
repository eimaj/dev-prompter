# Devkit — Examples

Read on demand, when unsure of a prompt's shape. The rules live in [`SHARED.md`](SHARED.md) and [`dispatch.md`](dispatch.md); where an example and a rule disagree, the rule wins.

### Example A — `/dev` (inline, small task; write → review → learn)

User: "rename the `trackEvent` function to `logEvent` in analytics.ts"

Model: `haiku` (informational — mechanical single-file rename, run inline).

Prompt (run directly):
```
You are a codebase editor. Your only job is to rename a function across a single file.

## Context
- Working directory: ~/Code/textnow-mono
- File: apps/web/src/analytics.ts

## Task
Rename all occurrences of `trackEvent` to `logEvent` in analytics.ts.
Update the export and all internal call sites in the same file.
```

Execution: Claude applies the edit inline (no Agent dispatch), then **reviews** via `/pr-review` on the working diff, then **learns** (clog if anything was surprising).

---

### Example B — `/dev-sa` (subagent, token-heavy; write → review → learn)

User: "find all call sites of trackEverflowConversion across the mono repo"

Model: `sonnet` · Subagent type: `Explore`

Prompt (dispatched):
```
You are a codebase explorer. Your only job is to find and map symbols, call sites, or files matching a given pattern.

## Context
- Working directory: ~/Code/textnow-mono
- Scope: all files under services/

## Task
Find all usages of `trackEverflowConversion` across services/.

Return: a bullet list of file:line for each call site.
Return only this. No intermediate output, no raw file contents.
```

Clog: `ACTION "dev-sa: dispatching 'find trackEverflowConversion call sites' to Explore subagent"`. If the subagent then edits code, run `/pr-review` on the change before the learn step.

---

### Example C — `/dev-tab` (interactive, supervised; write → review → learn)

User: "open a new tab to walk me through the PR review findings one by one"

Prompt (shown to user, written to file, then passed to herdr-tab):
```
You are facilitating a structured design review with me. Your only job is to walk me
through a set of findings one item at a time and record my decisions.

## Context
- Working directory: ~/Code/textnow-mono
- Review findings: ~/Code/logs/reports/dev-tab/2026-06-02-pr-review.local.md
- Background: PR #4821 — Everflow conversion tracking refactor

## Task
Present each finding (conflicts first, then gaps, then considerations).
After each one ask: "How would you like to handle this?" Wait for my response.
Confirm my decision in one sentence before moving to the next item.

## How to operate
One finding at a time. Do not proceed until I respond.
```

Execution: write prompt to `~/Code/logs/reports/dev-tab/YYYY-MM-DD-<slug>.local.md`, then run `~/.claude/skills/dev-tab/herdr-tab` with that file (requires `HERDR_ENV=1`).
Clog: `ACTION "dev-tab: opened cc on <pane> — PR #4821 review walkthrough"`
