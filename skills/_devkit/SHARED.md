# Devkit — Shared Prompt-Gen Base

This file is read by `/dev`, `/dev-tab`, `/dev-sa`, `/dev-sa-q`, and `/dev-tab-q` before any execution step.
It covers: persona lookup, the 4-part prompt contract, the two cycles (write→review→learn / write→learn), the ask-don't-assume rule, routing, the clog pattern, and examples.
It does **not** contain execution mechanics — those live in each thin SKILL.md.

---

## 1. Check the Task Personas Table

Before writing any prompt, open `~/.claude/agents/personas.md` and scan the **Task Personas** table.

- If a row matches the ask, copy the **Persona statement** column verbatim — do not paraphrase.
- If no row matches, derive one: `[role] + "Your only job is" + [task]`.
  - Add the new row to the table and commit: `chore(personas): add <name> task persona`.

---

## 2. The 4-Part Prompt Contract

Every prompt — run inline (`/dev`), dispatched to a subagent (`/dev-sa`, `/dev-sa-q`), or opened in a new pane (`/dev-tab`, `/dev-tab-q`) — is built from the same four parts, in order. A prompt missing any part is not ready to run.

### Part 1 — Model
The tier the work runs at: `haiku` | `sonnet` | `opus`, passed as the Agent tool `model` param. Recommend a tier with a one-line why — never assume it silently.

| Tier | Use for |
|---|---|
| `haiku` | cheap, mechanical, high-volume, low-ambiguity (bulk edits, simple extraction, file moves, format conversions) |
| `sonnet` | the default — balanced reasoning for most research, review, and writing tasks |
| `opus` | hard reasoning, ambiguous/open-ended, high-stakes, or synthesis across many sources |

> For inline `/dev` the Model part is **informational only** — there is no dispatch, so nothing is passed to an Agent. Name the tier the work implies, then run it here in the current session.

### Part 2 — Persona
Who the agent is and what its singular job is. Copy the statement **verbatim** from the Task Personas table (§1) — do not paraphrase.

```
You are <persona statement from Task Personas table>.
```

### Part 3 — Request / Ask
The specific, scoped task plus ALL context the agent needs (a subagent or new pane has no memory of this conversation):
- Working directory / repo path
- Relevant file paths or glob patterns
- Background: 1–2 sentences

```
## Context
- Working directory: <path>
- Relevant files:
  - <path> — <what it is>
- Background: <1–2 sentences>

## Task
<specific, scoped, unambiguous description>
```

### Part 4 — Deliverable
The exact return format. Wording differs by surface:

| Surface | Deliverable closing |
|---|---|
| `/dev` (inline) | _(no special closing — output appears in this session)_ |
| `/dev-sa`, `/dev-sa-q` (subagent) | `Return only this. No intermediate output, no raw file contents unless explicitly requested.` |
| `/dev-tab`, `/dev-tab-q` (new pane) | _(no "Return only this" — this is an interactive session)_ |

Subagent prompts (`/dev-sa-q`, and any `/dev-sa` dispatch) may also carry a **Logging block** after the Deliverable so logging discipline propagates into the delegated context — see §6.

---

## 3. The Two Cycles

Each skill runs one of two cycles. The **write** step is the surface-specific work (inline / in-subagent / in-pane); the other steps are shared.

| Family | Skills | Cycle |
|---|---|---|
| dev | `/dev`, `/dev-tab`, `/dev-sa` | **write → review → learn** |
| sa (quick, `-q`) | `/dev-sa-q`, `/dev-tab-q` | **write → learn** (no review) |

- **write** — do the work on the chosen surface (inline, in the subagent, or in the new pane).
- **review** — dispatch the `/pr-review` skill on the resulting change: an advisory, multi-lens review that never posts and never blocks. **Only the dev family reviews.** Run it once the change exists — inline for `/dev`, after the subagent returns for `/dev-sa`, in or after the pane for `/dev-tab`.
- **learn** — `clog` a LEARNING (agent meta-feedback: a prompt gap, a corrected assumption, a reusable delegation tactic) or LESSON (a reusable concept) capturing what was surprising or worth keeping. **All five skills do this.**

The `sa` family deliberately skips review: it exists to delegate a scoped task on a confirmed 4-part contract and return the result, not to gate the change through a review pass. Reach for a dev-family skill when you want the review step.

---

## 4. Ask, Don't Assume (all skills)

If scope, deliverable, or a material unknown leaves a **real gap** that would change the prompt, ask — use the `AskUserQuestion` tool — before proceeding. Never assume your way past a genuine gap. Typical gaps:
- **Scope boundaries** — which dirs / files / repos are in or out.
- **Deliverable format** — a list? a file? a diff? a table? a yes/no + evidence?
- **Depth** — quick scan vs thorough sweep (this also drives the model tier).

Otherwise, **proceed.** There is no blanket "show the assembled prompt and wait for explicit approval" gate, and no mandatory model-confirmation round — draft the 4-part prompt and go. Ask only when there is something real to resolve; if the user already answered a gap in their request, don't re-ask it.

This ask-on-real-gaps rule is the one gate `/dev-sa-q` and `/dev-tab-q` keep.

---

## 5. Routing Decision Table

| Signal | Route |
|---|---|
| Small task, fast, needs real-time iteration or back-and-forth | `/dev` |
| Token-heavy: many file reads, grep scans, log analysis, multi-step research that would bloat parent context; want it reviewed after | `/dev-sa` |
| Supervised / step-by-step / long-running dev work driven from a new pane | `/dev-tab` |
| Delegate a scoped task on a deliberate 4-part contract, return the result — no review pass | `/dev-sa-q` |
| Same deliberate contract but driven interactively from a new pane — no review pass | `/dev-tab-q` |
| The review step for any dev-family change (advisory, multi-lens) | `/pr-review` |
| Multi-phase (write → review → retro) with tracked artifacts | `/orchestrate` |

**When in doubt:**
- Would intermediate output clutter this session? → a subagent skill (`/dev-sa` or `/dev-sa-q`).
- Does the user need to interact with each step? → a pane skill (`/dev-tab` or `/dev-tab-q`).
- Should the change get an advisory review afterward? → a dev-family skill (they run `/pr-review`); otherwise the sa family.
- Is it quick and self-contained? → `/dev`.

---

## 6. Clog Logging Pattern

Log every dispatch, every completion, and the **learn** step. Use these exact command shapes:

### Before dispatching (subagent / pane surfaces)
```bash
clog ACTION "dev-sa: dispatching '<one-line task summary>' to <subagent-type> subagent"
```
```bash
clog ACTION "dev-sa-q: dispatching '<one-line summary>' to <subagent_type> subagent (model: <tier>, persona: <name>)" --agent dev-sa-q
```
```bash
clog ACTION "dev-tab: opened cc on <pane> — <one-line task summary>" --session "$CLAUDE_SESSION_ID"
```

### After completion (subagent / pane)
```bash
clog ACTION "dev-sa: '<task>' complete — <one-line summary of result>"
```

### If files were changed
```bash
clog CODE "<description of what changed in <filename>>"
```

For `/dev` (inline), log the result after the work is done:
```bash
clog CODE "<description of what was implemented>"
```

### The learn step (all skills)
Close the cycle with a LEARNING or LESSON when the run surfaced something reusable:
```bash
clog LEARNING "<what was surprising / a prompt gap / a delegation tactic>" --family dev --kpi <effective|prompt_gap|failure>
```

**On failure or timeout** — never leave it silent:
```bash
clog FOLLOWUP "dev-sa: '<task>' FAILED — <symptom>; retry with <narrower scope>"
```

### Logging block for delegated prompts
When a subagent's work is itself log-worthy, append this to the generated prompt (after the Deliverable) so the subagent logs as it works:
```
## Logging (required — log in real time, not batched at the end)
Log every meaningful step with `clog <TYPE> "<summary>" --agent <persona-slug>`:
- DECISION — each choice + why       - ACTION — each state-changing step
- CODE — each file created/edited    - LEARNING — anything surprising / a wrong assumption / a gap
- FOLLOWUP — anything left undone, blocked, or needing a retry
Do NOT batch. In your final return, add a one-line note of what you clogged.
```

---

## 7. Examples

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
- Review findings: ~/Code/notes/reports/dev-tab/2026-06-02-pr-review.local.md
- Background: PR #4821 — Everflow conversion tracking refactor

## Task
Present each finding (conflicts first, then gaps, then considerations).
After each one ask: "How would you like to handle this?" Wait for my response.
Confirm my decision in one sentence before moving to the next item.

## How to operate
One finding at a time. Do not proceed until I respond.
```

Execution: write prompt to `~/Code/notes/reports/dev-tab/YYYY-MM-DD-<slug>.local.md`, then run `~/.claude/skills/dev-tab/herdr-tab` with that file (requires `HERDR_ENV=1`).
Clog: `ACTION "dev-tab: opened cc on <pane> — PR #4821 review walkthrough"`
