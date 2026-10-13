---
name: capturing-task-lessons
description: Use at the end of a long or painful task to mine this session's transcript for durable lessons and route each one to a concrete edit — a skill, a memory, a team convention, or a lint/guard. Triggers include "capture ce qu'on a appris", "reflect", "fais une rétro", "pour que ça ne se reproduise pas". Presents Accepted/Rejected/Backlog and waits for approval before applying anything.
---

# Capturing task lessons

## Why this skill exists

A session that goes well produces institutional knowledge — a trap in a migration runner, a brief
that produced the wrong thing, a check that proved nothing. That knowledge survives only if someone
writes it down and routes it to a layer that will actually enforce it: a memory, a skill edit, a
guard, or a team convention.

This skill runs **after** the work. Use the session transcript as its evidence.

## When NOT to invoke

Skip when the session was trivial, when it was pure exploration, or when an existing skill already
covered the situation and was followed correctly. **A one-off is not a lesson.** A thing that went
wrong once, for a reason that will not recur, produces no edit.

## Process

### 1. Locate the transcript

Claude Code stores one directory per working directory under `~/.claude/projects/`, named after the
absolute path with `/` replaced by `-`. This session: `<project-dir>/<session-uuid>.jsonl`.
Subagents: `<project-dir>/<session-uuid>/subagents/agent-<id>.jsonl` alongside `.meta.json`.

```bash
ls -t ~/.claude/projects/<project-slug>*/*.jsonl | head -10
```

**Glob `<project-slug>*`, not the exact slug.** A session run inside a worktree writes to its own
project directory (`<project-slug>--claude-worktrees-<name>/`), and implementing in a worktree then
dropping it is a normal workflow. Globbing only the main directory makes the whole pass silently
blind to the run you most want to learn from. Never read another project's directory.

Confirm the file by reading its first lines and matching the opening user prompt. If no path
resolves, write a tight digest of the session and pass that to the reviewers instead.

### 2. Spawn three reviewers in parallel

Two `Agent` calls and one Codex call, issued together. **The `Agent` tool cannot run a Codex
model**, so the tooling lens goes out through Bash
(`codex exec -m <large-codex-model> -s read-only -o <file> "<prompt>" < /dev/null`, per
`delegating-to-codex`). If Codex is not installed, run it as a third `Agent` on a different tier and
say so. Each reviewer gets its template verbatim, with the transcript path or the digest
substituted where marked. The templates live in this skill's `references/` directory.

| Lens | Runner | Template |
|---|---|---|
| Judgment — what decision was wrong, and what rule would have prevented it | `Agent`, strongest tier | `references/judgment-reviewer.md` |
| Tooling — what check, script, or guard was missing | Codex (large model), via Bash | `references/tooling-reviewer.md` |
| Divergent — what nobody in the session questioned | `Agent`, strongest tier | `references/divergent-reviewer.md` |

The tooling lens goes to a different model family on purpose: a session reviewing itself with the
same model reproduces its own blind spots.

### 3. Synthesize

One `Agent` call on the strongest tier with every reviewer's full output inlined, following
`references/synthesizer.md`. It returns a structured **Accepted / Rejected / Backlog** list, each
Accepted item carrying a Routing field.

### 4. Structural enforcement check

Before presenting, sanity-check the Accepted list yourself. **For any item that a mechanism would
enforce more reliably than a sentence, move it from Accepted to Backlog with the mechanism named.**
The mechanisms, strongest first:

1. a type or a domain exception that makes the wrong state unrepresentable
2. a boot-time guard that refuses to start
3. a lint rule, or a task-runner input that stops a stale cache going green
4. a test in the suite that fails on the mistake
5. a line in a skill

A rule that lands at level 5 when level 1 was available becomes the next agent's template for doing
it the weak way.

### 5. Present and wait

**Show the full Accepted / Rejected / Backlog output and wait for the user to pick.** Do not apply
anything first. Skill and rule edits change every future session, and no edit gets applied without
the user's explicit choice. The user picks the subset and may redirect any routing.

### 6. Apply the approved subset

Follow each Routing field exactly. The destinations, and which one a lesson belongs in:

| Lesson shape | Destination |
|---|---|
| A non-obvious fact about the repo, a dump, or a tool that cost time to discover | the developer's own agent memory, plus its index line |
| A procedure or a trap inside an existing workflow | edit that skill's body |
| An operating rule | if it is durable for the team, ask before writing it to the project's agent rules file |
| A durable team convention | **ask before writing.** It belongs in the shared agent rules file (`CLAUDE.md` / `AGENTS.md`), which needs a PR |
| A finding worth doing later, not now | a working backlog note in a gitignored folder, with the reason |

Before writing a memory, check whether one already covers it and update that file instead of adding
a duplicate. Do not record what the repo already encodes — code structure, git history, or a rule
already in the agent rules file.

A new skill is rare. Prefer editing an existing one: *reuse or modify what exists rather than add*
applies to skills as much as to code.

### 7. Summarize

Short list, no preamble: edits applied with paths, memories written, backlog entries filed, and one
line per rejected finding with the reason.

## Provenance

Ported from `reflect` in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)
(Lauren Tan, MIT). The lens structure and the structural-enforcement check are theirs; the routing
table and the transcript paths are ours.
