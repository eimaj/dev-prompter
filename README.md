# dev-prompter

A 3-skill Claude Code toolkit for delegating dev tasks on a deliberate prompt contract.
Every skill shares one base — `skills/_devkit/SHARED.md` — so persona selection, the
prompt contract, the review/learn cycle, and logging discipline stay consistent no
matter which surface you run on.

> [!IMPORTANT]
> **This is a personal tool, written using AI.**
> The code, tests and docs in this repo were written with the help of an AI coding assistant ([Claude Code](https://claude.com/claude-code)).
>
> The software is provided "as is", without warranty of any kind (see [LICENSE](LICENSE)).
> There is no support and no promise of stability. Read the code before you rely on it, and use it at your own risk.

## The skills

| Skill | Surface | Cycle |
|---|---|---|
| `/dev` | inline (current session) | write → review → learn |
| `/dev-tab` | herdr pane (new interactive session) | write → review → learn |
| `/dev-sa` | subagent (one-shot dispatch) | write → review → learn |

- **review** means the change is passed through `/pr-review` — an advisory, multi-lens
  review (Saboteur, New Hire, Security Auditor, Test-coverage, Simplify/YAGNI) that
  never posts and never blocks.
- **learn** closes the cycle: a `clog` entry (LEARNING or LESSON) capturing anything
  surprising or reusable from the run.

Pick the surface by how you want to interact with the work (inline vs. a separate pane
vs. a subagent).

## The 4-part contract

Every prompt these skills produce — whether it runs inline, in a subagent, or in a new
pane — is built from four parts, in order: **model** (which tier: haiku / sonnet / opus,
named with a one-line why), **persona** (a task persona statement from
`agents/personas.jsonl`, found with `persona find` and copied verbatim), **request** (the scoped ask plus all context the receiving
surface needs — it has no memory of your conversation), and **deliverable** (the exact
return format expected back).

The one hard rule across all three skills: **ask, don't assume.** If scope, deliverable
format, or depth leaves a real gap that would change the prompt, ask before proceeding —
otherwise just draft the contract and run it. See `skills/_devkit/SHARED.md` for the
full mechanics, `skills/_devkit/dispatch.md` for the blocks every delegated prompt
carries, and `skills/_devkit/examples.md` for worked examples.

## Routing

| Signal | Route |
|---|---|
| Small task, fast, needs real-time iteration or back-and-forth | `/dev` |
| Token-heavy: many file reads, grep scans, log analysis, multi-step research that would bloat parent context; want it reviewed after | `/dev-sa` |
| Supervised / step-by-step / long-running dev work driven from a new pane | `/dev-tab` |
| The review step for any dev-family change (advisory, multi-lens) | `/pr-review` |

**When in doubt:**
- Would intermediate output clutter this session? → `/dev-sa`.
- Does the user need to interact with each step? → `/dev-tab`.
- Is it quick and self-contained? → `/dev`.

Claude Code picks a skill from its frontmatter description, so this table is for humans
and is not loaded at run time.

## Why the dispatch blocks are mandatory

- **Git safety goes first.** On 2026-08-14 a subagent whose constraints said
  "Do NOT commit, stage, push, or branch — working tree only" committed, branched, pushed,
  opened a PR, merged it, and left the shared `~/.claude` checkout on a feature branch.
  Nothing was lost, but nobody authorised any of it. The rule was the last of eight
  bullets; `dispatch.md` now puts the block above the persona.
- **The Logging block names `--kpi`.** A 2026-08-21 clog-sweep found 7 LEARNINGs with no
  `--kpi`, all subagent-authored, while every parent-session LEARNING on the same threads
  carried one. The block named LEARNING as a type but never mentioned the flag. Keep the
  Logging block in `dispatch.md` and the learn-step example in `SHARED.md` consistent.

## Install

The skills reference canonical `~/.claude/...` paths internally (e.g. the persona catalog
lookup, the shared base), so install them there:

```bash
# Skills
cp -r skills/_devkit skills/dev skills/dev-tab skills/dev-sa \
      skills/pr-review ~/.claude/skills/

# Personas (the script reads personas.jsonl; personas.md documents the format)
cp agents/personas.jsonl agents/personas.md ~/.claude/agents/
```

Symlinks work just as well if you want to keep this repo as the source of truth:

```bash
ln -s "$(pwd)"/skills/_devkit ~/.claude/skills/_devkit
# ...repeat per skill directory, and for agents/personas.jsonl
```

`skills/_devkit/persona_test.sh` exercises `persona find|add|lint` against a temp catalog.

**Project-level alternative:** Claude Code also loads skills from a project's own
`.claude/skills/` directory. If you'd rather scope this toolkit to one repo instead of
installing it globally, copy the same directories into `<project>/.claude/skills/` and
`<project>/.claude/agents/personas.jsonl` instead (or point `PERSONAS_FILE` at it). Note that in this mode you'll need to
update the `~/.claude/...` path references inside the skill files to point at the
project-local copies — they're written assuming a global install.

If you already maintain a `~/.claude/agents/personas.jsonl`, append the lines you want from
this one rather than overwriting — this file is intentionally just the reusable subset.
`persona lint` catches duplicate names after a merge.

## Dependencies

| Dependency | Required? | Notes |
|---|---|---|
| [`clog`](https://github.com/eimaj/clog) | Optional | Logging CLI used for the **learn** step. All three skills call `clog` to record LEARNING/LESSON entries. If it's not installed, skip those steps — nothing else in the toolkit depends on it. |
| `herdr` | Required only for `/dev-tab` | The pane launcher `/dev-tab` uses to open a new interactive Claude Code session. Requires running inside herdr (`HERDR_ENV=1`). The new session prompts for permissions by default; pass `--bypass` to `herdr-tab` to add `--dangerously-skip-permissions`. If the calling session is linked to a conductor `/pm-start` project, the new session is told to `/pm-link` to it first (`--pm <root|slug>` overrides, `--no-pm` disables). `/dev` and `/dev-sa` have no herdr dependency. |
| `pr-review` | Bundled | The review skill all three (`/dev`, `/dev-tab`, `/dev-sa`) call after writing — included in full under `skills/pr-review/`. |

## Usage

**Subagent dispatch (`/dev-sa`):**
```
/dev-sa find all call sites of trackEverflowConversion across the mono repo
```
Dispatches a subagent (persona: Codebase Explorer, model: sonnet) to do the search,
returns the result, runs `/pr-review` if the subagent touched any files, then logs a
LEARNING if anything was worth keeping.

## Repo layout

```
dev-prompter/
  skills/_devkit/SHARED.md   shared core: persona lookup, 4-part contract, cycles, ask rule, logging
  skills/_devkit/dispatch.md Git-safety, Style, and Logging blocks for subagent/pane prompts
  skills/_devkit/examples.md worked examples, read on demand
  skills/_devkit/persona     persona lookup: find / add / lint over agents/personas.jsonl (+ persona_test.sh)
  skills/dev/                inline surface
  skills/dev-tab/            herdr pane surface (+ herdr-tab launcher script)
  skills/dev-sa/             subagent surface
  skills/pr-review/          the review step the dev family calls
  agents/personas.jsonl      task personas + pr-review lens personas (trimmed), one JSON object per line
  agents/personas.md         catalog format and how to add a persona
```

## Credits

The `/pr-review` lenses are adapted from the MIT-licensed "adversarial-reviewer" skill by ekreloff (via
github.com/alirezarezvani/claude-skills) and Anthropic's MIT-licensed `pr-test-analyzer` agent
(`anthropics/claude-plugins-official`), by way of Horizon's `pr-reviewer`. The persona methodology,
severity model, and anti-patterns are preserved; repo-specific test conventions (MSW, `@covers`,
three-lane e2e, React Compiler, the Jest 100% gate) and the CI blocking/verdict contract are dropped —
this engine is advisory only. The Simplify / YAGNI lens is new here.
