# dev-prompter

A 5-skill Claude Code toolkit for delegating dev tasks on a deliberate prompt contract.
Every skill shares one base — `skills/_devkit/SHARED.md` — so persona selection, the
prompt contract, the review/learn cycle, and logging discipline stay consistent no
matter which surface you run on.

> 🧰 Part of a four-repo toolkit. See [eimaj/toolkit](https://github.com/eimaj/toolkit) for how
> the `/dev` family and `/pr-review` compose with [clog](https://github.com/eimaj/clog),
> [orchestrate](https://github.com/eimaj/orchestrate), and
> [project-manager](https://github.com/eimaj/project-manager) — including when to route a task
> to `/orchestrate` instead. This repo stands alone; none of them are required.

## The skills

| Skill | Surface | Cycle |
|---|---|---|
| `/dev` | inline (current session) | write → review → learn |
| `/dev-tab` | herdr pane (new interactive session) | write → review → learn |
| `/dev-sa` | subagent (one-shot dispatch) | write → review → learn |
| `/dev-sa-q` | subagent (one-shot dispatch) | write → learn (quick, no review) |
| `/dev-tab-q` | herdr pane | write → learn (quick, no review) |

- **review** means the change is passed through `/pr-review` — an advisory, multi-lens
  review (Saboteur, New Hire, Security Auditor, Test-coverage, Simplify/YAGNI) that
  never posts and never blocks.
- **`-q`** ("quick") skips the review step entirely — use it when you want the delegated
  result back fast and will eyeball it yourself.
- **learn** closes every cycle: a `clog` entry (LEARNING or LESSON) capturing anything
  surprising or reusable from the run. All five skills do this regardless of whether
  they review.

Pick the surface by how you want to interact with the work (inline vs. a separate pane
vs. a subagent), and the cycle by whether you want the change reviewed before you trust
it.

## The 4-part contract

Every prompt these skills produce — whether it runs inline, in a subagent, or in a new
pane — is built from four parts, in order: **model** (which tier: haiku / sonnet / opus,
named with a one-line why), **persona** (a task persona statement, copied verbatim from
`agents/personas.md`), **request** (the scoped ask plus all context the receiving
surface needs — it has no memory of your conversation), and **deliverable** (the exact
return format expected back).

The one hard rule across all five skills: **ask, don't assume.** If scope, deliverable
format, or depth leaves a real gap that would change the prompt, ask before proceeding —
otherwise just draft the contract and run it. See `skills/_devkit/SHARED.md` for the
full mechanics, routing table, and worked examples.

## Install

The skills reference canonical `~/.claude/...` paths internally (e.g. the persona table
lookup, the shared base), so install them there:

```bash
# Skills
cp -r skills/_devkit skills/dev skills/dev-tab skills/dev-sa skills/dev-sa-q \
      skills/dev-tab-q skills/pr-review ~/.claude/skills/

# Personas
cp agents/personas.md ~/.claude/agents/personas.md
```

Symlinks work just as well if you want to keep this repo as the source of truth:

```bash
ln -s "$(pwd)"/skills/_devkit ~/.claude/skills/_devkit
# ...repeat per skill directory, and for agents/personas.md
```

**Project-level alternative:** Claude Code also loads skills from a project's own
`.claude/skills/` directory. If you'd rather scope this toolkit to one repo instead of
installing it globally, copy the same directories into `<project>/.claude/skills/` and
`<project>/.claude/agents/personas.md` instead. Note that in this mode you'll need to
update the `~/.claude/...` path references inside the skill files to point at the
project-local copies — they're written assuming a global install.

If you already maintain a `personas.md` at `~/.claude/agents/personas.md`, merge the
**Task Personas** table here into yours rather than overwriting — this file is
intentionally just the reusable subset.

## Dependencies

| Dependency | Required? | Notes |
|---|---|---|
| [`clog`](https://github.com/eimaj/clog) | Optional | Logging CLI used for the **learn** step. All five skills call `clog` to record LEARNING/LESSON entries. If it's not installed, skip those steps — nothing else in the toolkit depends on it. |
| `herdr` | Required only for `/dev-tab` and `/dev-tab-q` | The pane launcher these two skills use to open a new interactive Claude Code session. Requires running inside herdr (`HERDR_ENV=1`). `/dev`, `/dev-sa`, and `/dev-sa-q` have no herdr dependency. |
| `pr-review` | Bundled | The review skill the `dev` family (`/dev`, `/dev-tab`, `/dev-sa`) calls after writing — included in full under `skills/pr-review/`. |

## Usage

**Reviewed subagent dispatch (`/dev-sa`):**
```
/dev-sa find all call sites of trackEverflowConversion across the mono repo
```
Dispatches a subagent (persona: Codebase Explorer, model: sonnet) to do the search,
returns the result, runs `/pr-review` if the subagent touched any files, then logs a
LEARNING if anything was worth keeping.

**Quick subagent dispatch, no review (`/dev-sa-q`):**
```
/dev-sa-q summarize the last 200 lines of this JSONL log into a status table
```
Dispatches the subagent on the same 4-part contract, returns the result, logs the learn
step — skips `/pr-review` entirely.

## Repo layout

```
dev-prompter/
  skills/_devkit/SHARED.md   shared base: personas, 4-part contract, cycles, routing
  skills/dev/                inline surface
  skills/dev-tab/            herdr pane surface (+ herdr-tab launcher script)
  skills/dev-sa/             subagent surface, reviewed
  skills/dev-sa-q/           subagent surface, quick
  skills/dev-tab-q/          herdr pane surface, quick
  skills/pr-review/          the review step the dev family calls
  agents/personas.md         task personas + pr-review lens personas (trimmed)
```
