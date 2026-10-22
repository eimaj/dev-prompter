# Devkit — Shared Prompt-Gen Base

Read by `/dev`, `/dev-tab`, `/dev-sa`, `/dev-sa-q`, and `/dev-tab-q` before any execution step: persona lookup, the 4-part prompt contract, the two cycles, the ask-on-real-gaps rule, and logging. Execution mechanics live in each SKILL.md.

- Dispatching surfaces (`/dev-sa`, `/dev-sa-q`, `/dev-tab`, `/dev-tab-q`) also read [`dispatch.md`](dispatch.md): the Git-safety, Style, and Logging blocks every delegated prompt carries.
- Read [`examples.md`](examples.md) only when unsure of a prompt's shape.

---

## 1. Look Up the Persona

Before writing any prompt, run `~/.claude/skills/_devkit/persona find <2-4 task keywords>`. It prints up to 5 `Name<TAB>statement` rows from the Task Personas table in `~/.claude/agents/personas.md`; do not read that file directly.

- If a row matches the ask, copy its statement verbatim — do not paraphrase.
- If none fits (exit 1, or no row matches), derive one: `You are a <role>. Your only job is <task>.` Record it with `~/.claude/skills/_devkit/persona add "<Name>" "<statement>" "<typical output>"`, which inserts the row inside the table. Leave committing to the user.

---

## 2. The 4-Part Prompt Contract

Every prompt — run inline (`/dev`), dispatched to a subagent (`/dev-sa`, `/dev-sa-q`), or opened in a new pane (`/dev-tab`, `/dev-tab-q`) — is built from the same four parts, in order. A prompt missing any part is not ready to run.

A dispatched prompt wraps the parts in fixed blocks from `dispatch.md`, in this order: [Git safety] → Persona → Request → Deliverable → [Logging] → [Style]. The Model part is not prompt text; it is the Agent `model` param or the `herdr-tab --model` flag.

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

## 5. Logging

Each SKILL.md gives its own dispatch and completion `clog ACTION` lines. The shared shapes:

- A file changed (inline, or the subagent/pane edited it): `clog CODE "<what changed in <file>>"`
- Failure or timeout — never leave it silent: `clog FOLLOWUP "<skill>: '<task>' FAILED — <symptom>; retry with <narrower scope>"`
- The learn step (all skills), when the run surfaced something reusable:

```bash
clog LEARNING "<what was surprising / a prompt gap / a delegation tactic>" --family dev --kpi <effective|prompt_gap|failure>
```
