---
name: init-skills
description: Use to equip a project with its own agent skills — detects the stack, task runner, tests, CI, git/PR conventions, ticket tool and runnable services, then generates proven project-local skills from the templates of this skills repo. Triggers include "init-skills", "initialise les skills de ce projet", "équipe ce repo en skills", "set up agent skills for this project". Also to re-run on a project whose skills are stale.
---

# Init skills

Turn the templates of this skills repo into concrete, **proven** skills for the current project.
Templates live in `<skills-repo>/templates/`; resolve `<skills-repo>` from this skill's own
directory (two levels up, following symlinks: `realpath <this-skill-dir>/../..`). Read
`templates/README.md` first: it defines the template contract this skill executes.

**Few proven skills beat many guessed ones.** Every generated skill must have had its commands
executed in this project. A skill you could not prove is delivered as a draft, labelled as such, or
not at all.

## Step 0 — Preconditions

- Run from the project's root (`git rev-parse --show-toplevel`). Not a git repo → stop and say so.
- Inventory what already exists: `.claude/skills/`, `.claude/agents/`, `.claude/commands/`,
  `.agents/skills/`, `CLAUDE.md`, `.claude/CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`. **Existing
  skills are kept**: for each template, an existing skill covering the same ground is updated only
  with the user's go, never overwritten.
- Note whether the working tree is clean. Generation writes files; the user should be able to review
  them as one diff.

## Step 1 — Detect, in parallel

Spawn read-only `Explore` subagents concurrently, one per area. Each gets the **Detect** table of the
relevant template verbatim and returns facts with evidence (`file:line` or a command and its output),
never guesses:

| Agent | Covers | Template section |
|---|---|---|
| stack & runner | languages, package managers, task runner, projects/packages, gate commands, caching, generated artifacts | `task-runner-and-tests` → Detect |
| tests | frameworks, markers, fast loop, test infra, fresh-checkout files, conventions | `task-runner-and-tests` → Detect |
| git & CI | base branch, naming, commits, PR template and language, CI jobs, freshness checks, migrations, changelog, stacking | `git-and-pr` → Detect |
| runtime | runnable surfaces, launch, ports/hostnames, auth, observable state, paid dependencies | `verification` → Detect |

Also ask the runtime agent which ticket tool is in use (branch names, PR bodies, connected MCP
servers).

Subagents **do not run gates or start services** — that happens in Step 5, once, under your control.

## Step 2 — Propose

Present one table, in the user's language, and wait for the go:

| Skill | Template | Decision | Why (evidence) | Key values detected |
|---|---|---|---|---|
| `running-tasks` | task-runner-and-tests | ✅ generate | `moon.yml` in 6 projects; CI runs `moon run :lint` | runner=`moon`, fast=`moon run <p>:check` |
| `stacking-branches` | git-and-pr | ⏭️ skip | no PR based on a non-default branch in the last 50 | — |
| `verifying-backend-api` | verification | ✅ generate | FastAPI on :5002 + Postgres in compose | auth = seeded admin token |

Below the table, list the generic skills of this repo that apply as-is (they are installed
globally, not copied): `grill-me`, `brainstorming`, `sum-up`, `pr-comments`,
`writing-manual-test-scenarios`, `explain-diff-html`, `capturing-task-lessons`,
`logging-decision-trails`, `evaluating-skill-changes`, `delegating-to-codex`,
`creating-verification-skills`, `maintaining-verification-skills`.

## Step 3 — Fill the gaps

Collect the **Ask** items of every selected template that detection could not settle, and ask them
in one round, numbered, each with the template's recommended default (the `grill-me` format). Never
ask for a fact a command can establish.

## Step 4 — Generate

For each approved skill:

1. Fill the template's **Skeleton** with the detected and answered values. Keep or drop each
   `[[if]]` block; remove the markers.
2. Write it to `.claude/skills/<name>/SKILL.md` (plus `references/`, `scripts/`, `features/` the
   template calls for). Make shipped scripts executable.
3. Carry over the template's **Lessons baked in** that apply, as rules with their reason — not as a
   separate essay.
4. Check: no `{{` or `[[` left (`grep -rn '{{\|\[\[' .claude/skills/<name>`), frontmatter has
   `name` and a `description` with real trigger phrases and a "not for" clause.

For `verifying-<surface>`, hand over to `creating-verification-skills` with the runtime facts
already detected, instead of repeating its interview.

## Step 5 — Prove

Run each template's **Prove** section in the project. Record, per skill: each command, its exit
code, its duration. Fix the skill (not the project) when a command is wrong, and re-run.

- A gate that fails because the **project** is broken (red test on the base branch, missing
  service) is reported, and the skill is still delivered if its commands are right.
- Anything that starts a process or a worktree is torn down afterwards; check nothing is left
  (`git worktree list`, the PIDs you started).
- A proving run that would cost money (paid API) waits for the user's explicit go.

## Step 6 — Wire it up

- Add a short **Skills** section to the project's agent rules file (`.claude/CLAUDE.md`, else
  `CLAUDE.md`, else create `AGENTS.md`), one line per generated skill: when to use it. Ask before
  editing a rules file that is shared with a team.
- If the user also works with Codex, expose the same skills to it (Codex reads `SKILL.md` folders
  too): check where this Codex version reads project skills (`codex --help`, its docs — commonly
  `.agents/skills/`), add a relative symlink to `.claude/skills/<name>`, and confirm Codex lists
  them. Never duplicate the files.

## Step 7 — Report

A table: skill | path | status (`proven` / `draft — <why>`) | proof (commands run, exit codes).
Then: skipped templates with the reason, open questions, and one line suggesting
`capturing-task-lessons` after the first real tasks, which is how these skills get their next
project-specific lessons.

Do not commit. The user reviews the diff and commits.

## Re-running on a project

Detect again, then diff detected facts against what the existing generated skills say (commands,
base branch, runner, surfaces). Propose updates only where a fact changed, with the evidence. For
verifying skills, defer to `maintaining-verification-skills`.
