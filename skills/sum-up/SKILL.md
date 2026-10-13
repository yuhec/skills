---
name: sum-up
description: Use to explain what a branch or PR does so the user can own it without cognitive debt — a short, schematic walkthrough of the files touched, the flow and the data at each step. Triggers include "sum-up <branche>", "résume cette PR", "explique-moi ce que fait la branche X", "retrace ce que tu as fait", "fais-moi un résumé schématique", "je veux m'approprier cette PR". Not for a code review (use reviewing-code) and not for a decision log.
---

# Sum-up of a branch

Input: a branch name. If none is given, use the current branch.

The goal is ownership, not exhaustiveness: after reading, the user can explain the change, find
any file in it, and predict what the code does on a given input. **Schemas and tables over
prose.** A sentence earns its place only when a schema cannot carry the point.

## Step 1 — Read the real diff, not memory

- Base: the PR base if a PR exists (`gh pr view <branch> --json baseRefName`), otherwise the
  repo's default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`).
- `git diff --name-status $(git merge-base origin/<base> <branch>)..<branch>` for the file list,
  then read the changed code. A summary built from the conversation drifts from what was pushed.
- Stacked branch: summarize only its own diff against its base branch, and say in one line which
  PR it sits on.

## Step 2 — Write the answer, in this order, in the user's language

**1. One line**: what the user can now do that they could not before.

**2. Files touched** — a table grouping every file of the diff, with counts. Groups, in this
order, dropping empty ones:

| Group | Count | Why |
|---|---|---|
| Backend code | n | the roles, e.g. comparison, orchestration, validation, API ↔ domain ↔ DB transport; mention deleted files |
| Frontend code | n | … |
| Tests and factories | n | new behaviours covered, old scenarios adapted |
| Generated contract (OpenAPI, client) | n | the field/route exposed |
| Migrations | n | … |
| Changelogs | n | … |

Then one small schema per role showing which file calls which (`A ─► B ─► C`), one line per file.

**3. Flow with data** — take one concrete example input (a handful of named entities with their
relevant fields) and show it flowing through the main functions, numbered steps, the data shape
**before and after each function**:

```
① load        → roots = [A, B, C]
② key(p)      → A → (cat, {code: D1})   C → None
③ group       → [[A, B], [C]]
④ plan        → { B → A }
⑤ writes      → repoint B → A, soft delete B
```

Name the real functions of the diff at each step.

**4. Behaviour by mode** — when the change introduces a setting, a mode or a variant, a table with
one row per thing the code looks at and one column per mode:

| What is looked at | Mode 1 | Mode 2 |
|---|---|---|
| … | Always | Always |
| … | All | Only the chosen ones |
| edge case (absent, empty…) | — | what happens |

**5. The non-obvious "why"** — for each design choice a reader would question (an algorithm, an
indirection, a new type), a mini schema contrasting the naive alternative with what the code
does, and one line of reason. Pick the questions a newcomer to this diff would ask, not every
choice.

**6. Other entry points** (save path, API route, validation) — one arrow schema each, ending on
the outcomes and their HTTP status.

## Rules

- Keep it to what fits on one or two screens. Cut a section rather than shrink every section.
- Every name in a schema is a real symbol, file or field of the diff — no invented vocabulary.
- No review findings, no TODOs, no history of how the branch was built: this is a map of the
  current state.
- Answer in chat. End with one line offering to turn it into a shareable page.
