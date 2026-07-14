# PR Review — Output Format Reference

Loaded on demand from `pr-review/SKILL.md`. See top-level for target resolution, depth tiers, and
dispatch; see [`lenses.md`](lenses.md) for the per-lens prompts. Mirrors the `branch-diff` report
style (same emoji key, same `file:line` discipline) so the two tools read consistently.

---

## Consolidated Review Report

One report per review. Emit exactly one section per lens that ran — a `## <lens>` heading followed by
that lens's body. A lens that doesn't apply gets `N/A`; a lens that found nothing gets a single short
line. Do not add per-lens "strengths" sections, verdict lines, or emoji beyond the key below.

```
## PR Review: `<head>` vs `<base>`  (tier: <skip|standard|deep>)

### Summary
<1-2 sentence overview of what the change concretely does>

### Findings

| | Severity | Lens | File:Line | Issue → consequence |
|---|---|---|---|---|
| ❌ | critical | Security Auditor | `path/file.ts:L42` | what is wrong and the concrete consequence |
| ⚠️ | warning | Saboteur | `path/file.ts:L10-15` | edge-case bug and when it triggers |
| ⚠️ | warning | Test-coverage | `path/file.ts:L88` | untested behavior → regression a missing test would miss |
| 🤔 | note | New Hire | `path/file.ts:L120` | readability/maintainability concern |
| 🤔 | note | Simplify | `path/file.ts:L60` | over-engineering → simpler form to prefer |

### Per-lens detail

## Saboteur
<findings, or `No Saboteur findings.`>

## New Hire
<findings, or `No New Hire findings.`>

## Security Auditor
<findings, or `No Security Auditor findings.` — or `N/A` if no security/agent surface>

## Test-coverage
<gaps with the concrete regression each would catch, or `No meaningful coverage gaps.` — or `N/A`>

## Simplify
<over-engineering with the simpler form, or `No Simplify findings.` — or `N/A`>

SUMMARY: <n crit / n warn / n note>   (advisory triage line — NOT a PASS/FAIL gate)
```

## Emoji key (shared with branch-diff)

| Emoji | Meaning |
|---|---|
| ✅ | Good / no issues |
| ⚠️ | Warning — likely edge-case bug, regression risk, or maintainer trap |
| ❌ | Critical — data loss, security breach, or production outage (advisory) |
| 🤔 | Note — style, minor improvement, or a question for the author |

Map severity to emoji: `critical` → ❌, `warning` → ⚠️, `note` → 🤔.

---

## Suggested Comment (copy-paste, human-gated)

Always end with a pre-written comment the human can copy, edit, and post — the tool **never** posts it.
Write it as the reviewer would (constructive, brief, specific, referencing `file:line`), not as a bot.
If the review is clean, write a short approval.

```md
### Suggested Review Comment

<concise, constructive comment referencing specific files and lines; groups the must-fix items first,
then the nice-to-haves. If clean: a brief approval.>
```

Do not include a `gh pr review` post command by default — this engine is advisory and the delegating
tool (`gh-pr-review`, `watch-pr`) owns any human-gated posting flow and its own `PENDING HUMAN REVIEW`
banner.

---

## Rules

- **Every ⚠️/❌/🤔 finding must carry an exact `file:line` or `file:line-line`** in both the Findings
  table and the per-lens detail.
- Keep findings scoped to changed files or directly affected code paths evidenced by the diff.
- Do not present speculation as fact. If you must infer, label it `Inference:` and say why.
- Do not reprint large diff blocks — quote only the relevant line(s).
- De-duplicate across lenses: one row per underlying issue, in the most-specific lens's section.
- The `SUMMARY:` line is advisory triage only — it is never a gate and never blocks.
- Never post to GitHub. The suggested comment is a draft for the human.

## Optional local report file

When invoked standalone (not through a delegating tool that owns its own report path), write the
consolidated report to `$AI_NOTES_DIR/reports/pr-review/YYYY-MM-DD-pr-review-<head>.local.md`
(default `~/Code/notes/AI/reports/pr-review/`); create the directory if it doesn't exist. When a
delegating tool (`gh-pr-review`, `watch-pr`) invokes this engine, return the report inline and let
that tool own the file location and notifications.
