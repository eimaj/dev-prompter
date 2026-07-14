---
name: dev-sa-q
description: Delegate a scoped task to a subagent on a deliberate 4-part prompt contract (model + persona + request + deliverable), then return the result. The `-q` (quick) cousin of /dev-sa — asks only when there's a real gap (no mandatory clarifying round, no show-and-approve gate) and skips the review step. Cycle — write in the subagent, then learn (clog); no review. Not for interactive step-by-step work (/dev-tab) or a reviewed delegation (/dev-sa).
---

# /dev-sa-q — Quick (No-Review) Subagent Prompt Builder & Dispatch
<!-- Thin skill — the 4-part contract, cycles, and ask rule live in ~/.claude/skills/_devkit/SHARED.md -->

## Trigger

**Use when:** you want to hand a scoped task to a subagent on a deliberate contract — an explicit model tier, a named persona, a scoped request, and a clear deliverable — and get the result back. `-q` = quick: **no review pass**.
**Do NOT use when:**
- You want the change reviewed after (write → review → learn) → `/dev-sa`.
- The task needs real-time back-and-forth in this session → `/dev`.
- You want to drive a supervised session in a new pane → `/dev-tab` (reviewed) or `/dev-tab-q` (not).
- Multi-phase work with tracked artifacts (write → review → retro) → `/orchestrate`.

> **Last Reviewed**: 2026-07-14
> **Refresh Rule**: Event-driven — update when the Agent tool's `model` values, the personas file, or the prompt contract change.

## Related Skills

- [`dev-sa`](../dev-sa/SKILL.md) — same subagent surface but runs the dev cycle (write → **review** → learn); reach for it when you want `/pr-review` on the change.
- [`dev-tab-q`](../dev-tab-q/SKILL.md) — the same write → learn (no-review) cycle driven interactively from a new herdr pane.
- `~/.claude/skills/_devkit/SHARED.md` — the shared base: 4-part contract, ask-don't-assume rule, personas, clog pattern.

---

## Step 1: Read SHARED.md

Before doing anything else, read `~/.claude/skills/_devkit/SHARED.md`.

It contains: persona lookup (§1), the 4-part prompt contract — model → persona → request → deliverable (§2), the two cycles (§3), the ask-don't-assume rule (§4), routing (§5), and the clog pattern + Logging block (§6).

`/dev-sa-q` runs the **quick cycle: write → learn** (no review). Its defining trait is the deliberate 4-part contract — every `/dev-sa-q` prompt names all four parts before it fires.

---

## Step 2: write — Assemble the 4-part prompt and dispatch

1. **Build the contract** (SHARED.md §2): pick the model tier (recommend + one-line why), copy the persona **verbatim** from `~/.claude/agents/personas.md` (§1; derive-and-add a row if none fits), write the scoped request with all context, and state the deliverable — end subagent prompts with `Return only this. No intermediate output.`

2. **Ask only on a real gap** (SHARED.md §4). If scope / deliverable / depth is genuinely open, ask once via the `AskUserQuestion` tool. If the request already answers them, don't — there is **no** mandatory clarifying round and **no** show-and-approve gate. Draft and go.

   > This is the one gate `-q` keeps — everything else about the quick path is unceremonious.

3. **Pick the subagent type:**

   | Ask type | `subagent_type` |
   |---|---|
   | Search, find, grep, read/summarize logs or files | `Explore` |
   | Write files, run commands, edit code, research-then-write | `general-purpose` |
   | A named custom agent that matches the task | that agent's `name` (e.g. `pa-eod-wrap`) |

4. **Log the dispatch, then fire (foreground):**

   ```bash
   clog ACTION "dev-sa-q: dispatching '<one-line summary>' to <subagent_type> subagent (model: <tier>, persona: <name>)" --agent dev-sa-q
   ```

   ```
   Agent({
     description: "<3-5 word summary>",
     subagent_type: "Explore",   // or general-purpose / a named agent
     model: "sonnet",            // Part 1 tier — haiku | sonnet | opus
     prompt: "<the 4-part prompt (+ the Logging block from SHARED.md §6 when the subagent's work is log-worthy)>",
     run_in_background: false    // /dev-sa-q waits and returns the result
   })
   ```

   The generated prompt is **ephemeral** — fired, not saved. (If the user asks to keep it, write it to `~/Code/notes/prompts/YYYY-MM-DD-<slug>.md`.)

5. **Present the result:** extract the relevant parts — don't dump a long reply verbatim. Then log completion:

   ```bash
   clog ACTION "dev-sa-q: '<task>' complete — <one-line result>" --agent dev-sa-q
   ```

   Add a `clog CODE` per file if the subagent edited files; `clog FOLLOWUP` on failure/timeout — never leave a failure silent.

---

## Step 3: learn — clog a LEARNING / LESSON (no review)

`/dev-sa-q` skips the review step. Close the cycle instead: if the run surfaced something reusable about how to prompt or delegate, `clog LEARNING "..." --family dev --kpi <effective|prompt_gap|failure>`. If the subagent's return doesn't mention what it logged, note that as a LEARNING so the contract can be tightened.

## Rules

- **Deliberate 4-part contract** — model, verbatim persona, scoped request, explicit deliverable. Missing one → not ready. This is what distinguishes `/dev-sa-q` from a bare `/dev-sa`.
- **Ask only on real gaps** — no mandatory clarifying round, no recommend-and-confirm model ceremony, no show-before-fire gate. Recommend the tier with a one-line why and proceed; ask via `AskUserQuestion` only when a gap would change the prompt.
- **No review pass** — `/dev-sa-q` runs write → learn. Want `/pr-review` on the change? use `/dev-sa`.
- **Foreground by default** — `run_in_background:false`, so `/dev-sa-q` returns the result in-line.
- **Personas come from `~/.claude/agents/personas.md`** — verbatim, or derive-and-add a new row.
- **Log both layers** — `/dev-sa-q` clogs its dispatch, completion, and learn; and carries the Logging block into the subagent when the delegated work is itself log-worthy. Neither layer batches or skips.

## Signal Keywords
<!-- Comma-separated terms the skills collector uses to attribute learnings to this skill -->
dev-sa-q, subagent, delegate, prompt-builder, persona, model-tier, haiku, sonnet, opus, quick, ask-on-gaps, four-part-prompt, deliverable, dispatch, learn
