---
name: dev
description: Run a dev task directly in the current session — small, fast, needs real-time iteration. No subagent dispatch, no new tab. Cycle — write inline, then review the change via /pr-review, then learn (clog). Asks only on real gaps.
---

# Dev — Inline Execution (`/dev`)

## Trigger

**Use when:** the task is small, fast, or needs real-time iteration with the user. Output should appear in the main context. No dispatch overhead needed.

**Do NOT use when:**
- The task would read many files, run grep scans, or produce verbose intermediate output that bloats the parent session → use `/dev-sa` instead.
- The user wants to drive an interactive session step-by-step from a new pane → use `/dev-tab` instead.
- The task has multiple phases (write → review → retro) → use `/orchestrate` or `/dev-orchestrate`.

> **Last Reviewed**: 2026-06-02
> **Refresh Rule**: Event-driven — update if inline execution patterns change.

---

## Step 1: Read SHARED.md

Before doing anything else, read `~/.claude/skills/_devkit/SHARED.md`.

It contains: persona lookup, the 4-part prompt contract (model → persona → request → deliverable), the two cycles, the ask-don't-assume rule, the routing decision table, the clog pattern, and one example per surface.

---

## Step 2: write — Run the Task Inline

Draft the 4-part prompt (per SHARED.md §2 — for inline the Model part is informational, no dispatch), ask only if there's a real gap (§4), then implement the work directly in the current session:

- No `Agent()` dispatch.
- No new herdr pane.
- Claude applies edits, runs commands, and produces output here in the main context.
- Log the code after completion:

```bash
clog CODE "<description of what was implemented>"
```

---

## Step 3: review — `/pr-review` the change

Once the change exists, run the `/pr-review` skill on the working diff — an advisory, multi-lens review (never posts, never blocks). Surface its findings; don't act on them silently.

---

## Step 4: learn — clog a LEARNING / LESSON

Close the cycle: if anything was surprising or reusable, `clog LEARNING`/`LESSON` per SHARED.md §6.

---

## Signal Keywords
dev, inline, current session, run here, implement, quick task, small task, real-time, iterate, interactive, fast, review, pr-review, learn
