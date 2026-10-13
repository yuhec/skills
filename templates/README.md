# Templates

A template is a **pattern** extracted from a project where it was proven, stripped of everything
specific to that project. `init-skills` reads a template, detects the facts it needs in a target
project, and writes a concrete project-local skill. Templates are never installed as skills
themselves.

## Contract — every `TEMPLATE.md` has these sections, in this order

1. **Produces** — the skill(s) it generates, each with its target path
   (`.claude/skills/<name>/SKILL.md`) and whether it is required or optional.
2. **Applies when / Skip when** — the observable signals that make it relevant. A template whose
   signals are absent produces nothing, and `init-skills` says why.
3. **Detect** — the facts to establish, each with *where to look* and *how to confirm it by
   running something*. A fact read from config but never executed is a guess.
4. **Ask** — the few facts the code cannot tell (team policies). Each comes with a recommended
   default.
5. **Variables** — the table of `{{PLACEHOLDERS}}` the skeleton uses, and which detect/ask item fills
   each one.
6. **Skeleton** — the SKILL.md to write. `[[if <condition>]] … [[end]]` marks an optional block;
   drop the markers, keep or drop the block.
7. **Prove** — the commands to run in the target project before the generated skill is delivered.
   A generated skill whose commands were not executed is a draft.
8. **Lessons baked in** — why each rule in the skeleton exists, so a reader can judge whether it
   applies. Never delete a lesson from a generated skill without saying why it does not apply.

## Rules for a generated skill

- **No placeholder survives.** Every `{{VAR}}` is replaced by a real value from the project, or the
  block that needs it is dropped.
- **Real commands only**, each one executed at least once during generation.
- The `description` says *when* to reach for the skill, with the trigger phrases the user actually
  types (in their language), and what it is **not** for.
- Short beats exhaustive: a 40-line skill that is right beats a 200-line one that is half guessed.
  Lessons are added later by `capturing-task-lessons`, from real sessions.

## Available templates

| Template | Produces |
|---|---|
| [`task-runner-and-tests`](task-runner-and-tests/TEMPLATE.md) | `running-tasks`, `testing`, optional `writing-tests` |
| [`git-and-pr`](git-and-pr/TEMPLATE.md) | `pre-pr`, `syncing-branches`, `shipping-a-ticket`, `.claude/review-rules.md` (input of `reviewing-code`), optional `placing-changelog-fragments`, `stacking-branches` |
| [`verification`](verification/TEMPLATE.md) | `verifying-<surface>` with its feature map, via `creating-verification-skills` |
