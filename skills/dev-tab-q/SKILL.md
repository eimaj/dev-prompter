---
name: dev-tab-q
description: Open a new interactive Claude Code session in a separate herdr pane on a deliberate 4-part prompt contract (model + persona + request + deliverable). The `-q` (quick) pane cousin of /dev-tab — write in the pane, then learn (clog); skips the review step. Asks only on real gaps. Requires running inside herdr (HERDR_ENV=1). Use /dev-tab instead when you want the change reviewed via /pr-review.
---

# /dev-tab-q — Quick (No-Review) Deliberate-Contract Pane Session
<!-- Thin skill — the 4-part contract, cycles, and ask rule live in ~/.claude/skills/_devkit/SHARED.md -->

## Trigger

**Use when:** you want to open a new interactive Claude Code session in a separate herdr pane, pre-loaded with a deliberate 4-part contract (model + persona + request + deliverable), and drive it yourself from the new pane. `-q` = quick: **no review pass** — this is the pane cousin of `/dev-sa-q`.

**Requires herdr:** only works inside a herdr-managed pane (`HERDR_ENV=1`). Outside herdr the script hard-fails — use `/dev-sa-q` or `/dev` instead.

**Do NOT use when:**
- You want the pane's change reviewed after (write → review → learn) → `/dev-tab`.
- You want a one-shot result returned to this session → `/dev-sa-q` (no review) or `/dev-sa` (reviewed).
- The task is small and fast → `/dev`.
- Multi-phase work with tracked artifacts (write → review → retro) → `/orchestrate`.

> **Last Reviewed**: 2026-07-14
> **Refresh Rule**: Update if the herdr API, the `herdr-tab` script, or the prompt contract change.

## Related Skills

- [`dev-tab`](../dev-tab/SKILL.md) — same pane surface but runs the dev cycle (write → **review** → learn); reach for it when you want `/pr-review` on the change.
- [`dev-sa-q`](../dev-sa-q/SKILL.md) — the same write → learn (no-review) cycle dispatched to a one-shot subagent instead of a pane.
- `~/.claude/skills/_devkit/SHARED.md` — the shared base: 4-part contract, ask-don't-assume rule, personas, clog pattern.

---

## Step 1: Read SHARED.md

Before doing anything else, read `~/.claude/skills/_devkit/SHARED.md`.

It contains: persona lookup (§1), the 4-part prompt contract — model → persona → request → deliverable (§2), the two cycles (§3), the ask-don't-assume rule (§4), routing (§5), and the clog pattern (§6).

`/dev-tab-q` runs the **quick cycle: write → learn** (no review). Like `/dev-sa-q`, every prompt names all four parts before it opens the pane.

---

## Step 2: write — Open a herdr Pane

Draft the 4-part prompt (per SHARED.md §2), ask only if there's a real gap (§4), then:

1. **Write the prompt to a file:**

   ```
   ~/Code/notes/reports/dev-tab-q/YYYY-MM-DD-<slug>.local.md
   ```

   If the task is tied to a specific domain, use that path instead (e.g. `~/Code/notes/reports/<domain>/...`).

   Pane prompts are interactive — **do not include** "Return only this. No intermediate output." language (that closing is for subagent surfaces only).

2. **Invoke the script** (reused from `dev-tab` — do not duplicate it):

   ```bash
   ~/.claude/skills/dev-tab/herdr-tab /path/to/prompt.md
   ```

   The script splits a new herdr pane (right of current, focused) and runs `claude --verbose --dangerously-skip-permissions < <prompt-file>`. It targets the current pane via `HERDR_PANE_ID` and hard-fails if `HERDR_ENV` is not `1`.

   Use `--no-bypass` to skip `--dangerously-skip-permissions` (user handles permissions interactively).
   Use `--model <name>` to pin the new session's model to the Part 1 tier (e.g. `--model sonnet`).

3. **Log the pane reference:**

   ```bash
   clog ACTION "dev-tab-q: opened cc on <pane> — <one-line task summary>" --session "$CLAUDE_SESSION_ID"
   ```

---

## Step 3: learn — clog a LEARNING / LESSON (no review)

`/dev-tab-q` skips the review step. Close the cycle instead: if the run surfaced something reusable about how to prompt or delegate, `clog LEARNING "..." --family dev --kpi <effective|prompt_gap|failure>` per SHARED.md §6.

---

## Signal Keywords
dev-tab-q, new tab, herdr tab, herdr pane, interactive session, open cc, open claude, new pane, deliberate contract, four-part-prompt, persona, model-tier, quick, no review, learn
