---
name: dev-tab
description: Open a new interactive Claude Code session in a separate herdr pane. Use when the user wants supervised, step-by-step, or long-running work in a dedicated pane. Requires running inside herdr (HERDR_ENV=1). Cycle — write in the pane, then review the change via /pr-review, then learn (clog). Asks only on real gaps.
---

# Dev Tab (`/dev-tab`)
<!-- Thin skill — prompt-gen steps live in ~/.claude/skills/_devkit/SHARED.md -->

## Trigger

**Use when:** the user wants to open a new interactive Claude Code session in a separate herdr pane and pre-load it with a task or review prompt. The new session is fully interactive — the user drives it from the new pane.

**Requires herdr:** this skill only works when running inside a herdr-managed pane (`HERDR_ENV=1`). Outside herdr, the script hard-fails — use `/dev` or `/dev-sa` instead.

**Do NOT use when:**
- You need a one-shot result returned to this session → use `/dev-sa` instead.
- The task is small and fast → use `/dev` instead.
- The task has no natural back-and-forth (pure background work) → use the `Agent` tool directly.
- The task needs write/review cycles with tracked artifacts → use `/orchestrate` instead.

> **Last Reviewed**: 2026-07-08
> **Refresh Rule**: Update if the herdr API changes or cc alias changes.

---

## Step 1: Read SHARED.md

Before doing anything else, read `~/.claude/skills/_devkit/SHARED.md`.

It contains: persona lookup, the 4-part prompt contract (model → persona → request → deliverable), the two cycles, the ask-don't-assume rule, the routing decision table, the clog pattern, and one example per surface.

---

## Step 2: write — Open a herdr Pane

Draft the 4-part prompt (per SHARED.md §2), ask only if there's a real gap (§4), then:

1. **Write the prompt to a file:**

   ```
   ~/Code/notes/reports/dev-tab/YYYY-MM-DD-<slug>.local.md
   ```

   If the task is tied to an orchestrate run or specific domain, use that path instead (e.g. `~/Code/notes/reports/orchestrate/...`).

   Tab prompts differ from subagent prompts — **do not include** "Return only this. No intermediate output." language. This is an interactive session.

2. **Invoke the script:**

   ```bash
   ~/.claude/skills/dev-tab/herdr-tab /path/to/prompt.md
   ```

   The script splits a new herdr pane (right of current, focused) and runs `claude --verbose --dangerously-skip-permissions < <prompt-file>` (invoked directly — no reliance on the `cc` alias). It targets the current pane via `HERDR_PANE_ID` and hard-fails if `HERDR_ENV` is not `1`.

   Use `--no-bypass` to skip `--dangerously-skip-permissions` (user handles permissions interactively).
   Use `--model <name>` (e.g. `--model fable`) to pin the new session's model.

3. **Log the pane reference:**

   ```bash
   clog ACTION "dev-tab: opened cc on <pane> — <one-line task summary>" --session "$CLAUDE_SESSION_ID"
   ```

---

## Step 3: review — `/pr-review` the change

Once the pane's change exists, run the `/pr-review` skill on it — an advisory, multi-lens review (never posts, never blocks). Surface its findings.

---

## Step 4: learn — clog a LEARNING / LESSON

Close the cycle: if anything was surprising or reusable, `clog LEARNING`/`LESSON` per SHARED.md §6.

---

## Signal Keywords
dev-tab, new tab, herdr tab, herdr pane, interactive session, open cc, open claude, new pane, walkthrough, step by step, supervised session, permissionMode, bypassPermissions, autoMode, bare mode, agent view, review, pr-review, learn
