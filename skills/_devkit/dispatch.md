# Devkit — Dispatch Wrappers

Read by `/dev-sa`, `/dev-sa-q`, `/dev-tab`, and `/dev-tab-q` after [`SHARED.md`](SHARED.md). Inline `/dev` has no delegated context and skips this file.

Assemble every dispatched prompt (subagent or pane) in this order, copying each block verbatim:

1. The Git-safety block (§1) — first, above the persona.
2. Persona → Request → Deliverable (SHARED.md §2).
3. The Logging block (§3) — when the delegated work is itself log-worthy.
4. The Style block (§2) — last.

The Git-safety and Style blocks are **mandatory on every dispatched prompt**. A prompt without them is not ready to run.

---

## 1. Git safety

Put this block first, not in a constraints list near the end. A subagent that reads "do not commit" as the last of eight bullets weighs it against everything above it; one that reads it first treats it as the frame.

```
## Git safety (read this first — it overrides anything below)
Run NO git write commands. Not commit, add, stage, branch, switch, checkout,
push, pull, merge, rebase, stash, tag, reset, or `gh pr create|merge`.
Leave every change in the working tree, unstaged. Read-only git (status, diff,
log, show, ls-files) is fine.
The dispatching session owns shipping and has context you do not: which files
belong to other concurrent sessions, what may be pushed, and when. If the work
seems to call for a commit, say so in your return and stop.
```

Two carve-outs, and only when the dispatching session states them explicitly in the request:

- **The task IS the git operation** (e.g. "reconcile these two branches") — then replace the block with the precise commands allowed, and name the branch and remote.
- **Worktree-isolated work** — the dispatcher created the worktree and says so; the subagent commits only there, still never pushes.

Neither carve-out ever authorises `push`, `gh pr merge`, or a branch switch in a shared checkout. Those stay with the dispatching session, which is bound by the standing no-push-without-an-explicit-request-from-Jamie rule.

---

## 2. Style

Subagents default to verbose prose. Without this block, the delegated context returns walls of text.

```
## Style (required)
Lead with the next concrete action. Number multi-step work. One sentence where a
sentence will do — never a paragraph. Cap lists at 5, ranked; put the tail in the
file, not the reply. No preamble, no recap, no closing pleasantries.
Do not speculate: state only what you verified, and say "unverified" or omit it otherwise.
```

---

## 3. Logging block

When a subagent's or pane's work is itself log-worthy, put this after the Deliverable so the delegated context logs as it works. Keep the `--kpi` line: a LEARNING without it is invisible to the retro loop.

```
## Logging (required — log in real time, not batched at the end)
Log every meaningful step with `clog <TYPE> "<summary>" --agent <persona-slug>`:
- DECISION — each choice + why       - ACTION — each state-changing step
- CODE — each file created/edited    - LEARNING — anything surprising / a wrong assumption / a gap
- FOLLOWUP — anything left undone, blocked, or needing a retry
Every LEARNING needs `--kpi <effective|prompt_gap|failure>` — without it the entry is
invisible to the retro loop that reads these. `--family <name>` too when you know it.
Do NOT batch. In your final return, add a one-line note of what you clogged.
```
