---
name: logging-decision-trails
description: Use during long unattended runs, multi-phase migrations, multi-agent builds, or any work the user reviews after stepping away — keeps one append-only TSV with a row per decision (what, why, evidence, result), then audits it against the session transcript before handing back. Triggers include "garde une trace", "show me your work", "je veux pouvoir relire ce que tu as décidé".
---

# Logging decision trails

## Why this skill exists

A long run hands back a summary. The summary is written by the same agent that did the work, from
the same context that produced the mistakes, and it reads equally well whether or not the work is
sound. A trail written *as the run happens*, with a pointer to evidence on every row, is the thing
that lets someone come back hours later and check rather than trust.

Keep one canonical log. Not a log per phase, not a log plus a summary file.

## The format

A single TSV, one row per decision. Cells stay on one line. Evidence is a pointer, never prose.

| Column | Contents |
|---|---|
| `ts` | ISO8601 timestamp |
| `phase` | the phase or workstream |
| `decision` | what was chosen or done, one line |
| `why` | the reason in plain words |
| `evidence` | commit SHA, PR number, `file:line`, artifact path, or a test command. Never a paragraph |
| `result` | `tests green`, `reverted`, `boot OK`, `inconclusive`, `open` |

Write each row the way you would tell a teammate what you did. Plain words, concrete actions, no
jargon and no AI register.

```
ts	phase	decision	why	evidence	result
2026-01-10T09:02:00Z	scoping	counted 12 items, not 9	3 items had no ticket	app/domain/registry.py	3 items to ticket
2026-01-10T09:40:00Z	setup	restored the snapshot before touching code	needed a before/after comparison	scripts/restore.py	staging environment ready
2026-01-10T11:15:00Z	migration	re-timestamped the migration	a newer migration had already merged	commit 3a9f1c2	runner no longer skips it
2026-01-10T12:30:00Z	migration	discarded the subagent's run, its suite never ran	checked the files, not its summary	worktree reset	redone with a tighter brief
```

## Logging a row

Use the helper in this skill's `scripts/` directory, which stamps `ts`, writes the header on first
use, strips stray tabs and newlines, and quotes any cell starting with `=`, `+`, `-` or `@`:

```bash
<this-skill-dir>/scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>
```

Log decision points and checkpoints, not every action: a fork taken, a unit finished with its
verification result, a pivot or a revert with what triggered it, a blocker, a gate repaired. One row
per iteration for loop runs. Skip the trivial.

## Where it lives

`<working-docs-dir>/trails/<task-slug>.tsv`, where the working-docs dir is a gitignored folder of
the project (often `docs/` or `.local/`; check `git check-ignore` before writing). If the project
has none, use the session scratchpad.

**Do not commit the trail** unless the project explicitly wants it. If a reviewer needs it, paste
the relevant rows into the PR description instead. To read the trail in a terminal without relying
on `column` (missing in many containers):

```bash
python3 -c "import csv,sys;rows=list(csv.reader(open(sys.argv[1]),delimiter='\t'));w=[max(len(r[i]) for r in rows) for i in range(len(rows[0]))];[print('  '.join(c.ljust(w[i]) for i,c in enumerate(r))) for r in rows]" <trail>.tsv
```

This skill runs **during** the work. For mining lessons **after** it, use `capturing-task-lessons`:
the trail is one of its best inputs, and a request that asks for both wants this one first, then
that one.

## Rules

- One row is one decision or checkpoint.
- **Append-only.** A wrong call gets a new row that supersedes it. Never edit or delete history.
- Prefer evidence produced by a committed script over a hand-made one-off.
- `inconclusive` is a valid result and is not a pass. Never quietly upgrade it.

## Audit the log against the transcript

Before handing back, check that the log told the truth. The session transcript lives under
`~/.claude/projects/<project-slug>/<session-uuid>.jsonl`, with subagent transcripts under
`<session-uuid>/subagents/agent-<id>.jsonl`.

**A run that happened in a worktree wrote its transcript somewhere else** — worktree sessions get
their own project directory (`<project-slug>--claude-worktrees-<name>/`). Glob
`~/.claude/projects/<project-slug>*/`, or the audit silently covers nothing. Do not read other
projects' directories.

Walk the log against what actually happened:

- Every row maps to a real action. Cut invented or aspirational rows.
- Each row's evidence resolves and shows what the row claims.
- A fork, pivot, or abandoned approach that shaped the work but is not logged is a gap. Add it.
- Drop padding.

Fix the log, not the story. If the work diverged from what a row claims, the row is wrong.

## Cross-model review of the trail

For a run long enough to need a trail, have a second model read it. Route through
`delegating-to-codex` or spawn a subagent on a different tier. Self-review does not substitute. It
reads the trail and the transcript and flags what the user should look at:

- rows whose evidence is weak or missing
- verification claimed but absent from the transcript
- choices that look risky in hindsight (premature, scope-creeping, papering over a symptom)
- gaps a casual skim would miss

End every reply for a run that produced a trail with an **Attention** section: the reviewing model
on its own line, then one line per flag pointing at specific rows. `No flags` is a valid value.

## Composing with other skills

An end-to-end verification drill that spans a branch switch and an irreversible migration should
route here. Every other long run reaches this skill only because you invoked it, since its own
trigger is a judgment about the run's length that is easiest to get wrong while inside it. Decide
at the start of a long run, not in the middle. If a given kind of run keeps needing a trail, add the
reference to that run's own skill rather than restating the columns there.

## Provenance

Ported from `show-me-your-work` in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)
(Lauren Tan, MIT). Transcript paths, the worktree caveat and the do-not-commit rule are ours.
