---
name: dev-sa
description: Delegate the current ask to a one-shot subagent to protect the parent session from token-heavy work. Use when the task involves broad file reads, grep scans, log analysis, or multi-step research. Non-orchestrated — no Writer/Reviewer cycles. Cycle — write in the subagent, then review the change via /pr-review, then learn (clog). Asks only on real gaps.
---

# Dev Subagent Delegation (`/dev-sa`)
<!-- Thin skill — prompt-gen steps live in ~/.claude/skills/_devkit/SHARED.md -->

## Trigger

**Use when:** the current ask is research-heavy, requires reading many files, grep scans, log analysis, or any multi-step investigation where intermediate output would bloat the parent session's context.

**Do NOT use when:**
- The task requires real-time iteration with the user, or when the parent session must act on each step before the next can proceed → use `/dev` instead.
- The user wants to drive an interactive step-by-step session in a new pane → use `/dev-tab` instead.
- The task has multiple phases with tracked artifacts → use `/orchestrate` or `/dev-orchestrate`.

> **Last Reviewed**: 2026-06-02
> **Refresh Rule**: Event-driven — update when Agent tool subagent types or invocation patterns change.

---

## Step 1: Read SHARED.md

Before doing anything else, read `~/.claude/skills/_devkit/SHARED.md`.

It contains: persona lookup, the 4-part prompt contract (model → persona → request → deliverable), the two cycles, the ask-don't-assume rule, the routing decision table, the clog pattern, and one example per surface.

---

## Step 2: write — Dispatch via Agent()

Draft the 4-part prompt (per SHARED.md §2 — the Model part is the Agent `model` value), ask only if there's a real gap (§4), then:

1. **Choose the subagent type:**

   | Ask type | Subagent type |
   |---|---|
   | Search, find, grep, "where is X defined?" | `Explore` |
   | Read and summarize logs or large files | `Explore` |
   | Write files, run commands, edit code | `general-purpose` |
   | Multi-step: research then write an artifact | `general-purpose` |

   `subagent_type` also accepts any custom agent name matching a file in `.claude/agents/*.md` or `~/.claude/agents/*.md` — pass the agent's `name` field directly (e.g. `"subagent_type": "statusline-setup"`).

2. **Log the dispatch before calling Agent:**

   ```bash
   clog ACTION "dev-sa: dispatching '<one-line task summary>' to <subagent-type> subagent"
   ```

3. **Dispatch:**

   ```
   Agent({
     description: "<3-5 word summary>",
     subagent_type: "Explore",    // or "general-purpose"
     model: "sonnet",             // the Part 1 tier — haiku | sonnet | opus
     prompt: "<brief>",
     run_in_background: false     // wait for result before replying to user
   })
   ```

   Set `run_in_background: true` only when you have independent work to do in parallel.

4. **Present the result:** one or two sentences of framing, then the conclusion. Do not relay the subagent's full output verbatim if it is long — extract the relevant parts and summarize the rest.

5. **Log completion:**

   ```bash
   clog ACTION "dev-sa: '<task>' complete — <one-line summary of what the subagent found or changed>"
   ```

   If the subagent made file edits, also log a CODE entry for each file changed:

   ```bash
   clog CODE "<description of what changed in <filename>>"
   ```

   **On failure or timeout** (log this instead — do not leave failures silent):
   ```bash
   clog FOLLOWUP "dev-sa: 'scan loyalty service for proto dependency gaps' FAILED — subagent timed out at file scan step; retry with narrower scope"
   ```

   **Before file edits** (intent record — fires before the Edit tool call):
   ```bash
   clog CODE "about to edit services/loyalty/everflow/offers.go: add missing MustBeAll availability check"
   ```

> **Routing gate:** if the ask needs multiple phases (write → review → retro), will produce tracked artifacts, or involves iterative cycles, stop here and use `/orchestrate` instead. `/dev-sa` is for one-shot delegation — if the task has layers, it's the wrong tool.

---

## Step 3: review — `/pr-review` the change

If the subagent changed code, run the `/pr-review` skill on the change once it returns — an advisory, multi-lens review (never posts, never blocks). Surface its findings. (Pure read/research runs with no change to review skip straight to learn.)

---

## Step 4: learn — clog a LEARNING / LESSON

Close the cycle: if the run surfaced a prompt gap, a wrong assumption, or a reusable delegation tactic, `clog LEARNING`/`LESSON` per SHARED.md §6.

---

## Signal Keywords
dev-sa, subagent, delegate, offload, context-protection, token-heavy, exploration, research, Explore, general-purpose, review, pr-review, learn
