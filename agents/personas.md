# Agent Personas

Centralized reference for task personas used in subagent dispatch by the dev family
(`/dev`, `/dev-tab`, `/dev-sa`, `/dev-sa-q`, `/dev-tab-q`) and by `/pr-review`.

> This file is a trimmed excerpt of a larger personal personas file. It carries only the
> generic, reusable task personas (including the `/pr-review` lens personas), in `personas.jsonl`.
> Named-agent and voice/style personas are intentionally not included here — they're
> specific to one person's stack and writing voice, not reusable toolkit pieces.

## How to Use

Task personas live in [`personas.jsonl`](personas.jsonl), one JSON object per line:

```json
{"name": "Codebase Explorer", "kind": "task", "statement": "You are a codebase explorer. Your only job is ...", "deliverable": "..."}
```

- `kind` is `task` (reusable), `lens` (a `/pr-review` lens — the lens files quote these verbatim), or `one-off` (used for a single job; kept for reference, not suggested by default).
- Optional `notes` holds setup for the dispatcher (skills to load, context to include). It is never pasted into the prompt as part of the statement.
- Look up and add with `skills/_devkit/persona` (`find <query>`, `find --all`, `add`, `lint`), never by reading the whole file. Use the `statement` verbatim.

## Adding a New Task Persona

1. Write the one-off persona inline in the subagent prompt using `[role] + "Your only job is" + [task]`
2. If you use it more than once, add it with `persona add "<Name>" "<statement>" "<deliverable>"` (appends one line to `personas.jsonl`)
3. Leave committing to the dispatching session — do not commit the row yourself
