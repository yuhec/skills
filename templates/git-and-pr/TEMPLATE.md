# Template — git and PR workflow

## Produces

| Skill | Path | Required |
|---|---|---|
| `pre-pr` | `.claude/skills/pre-pr/SKILL.md` | yes, when the project has CI |
| `syncing-branches` | `.claude/skills/syncing-branches/SKILL.md` | yes, when the project uses PRs against a shared base branch |
| `shipping-a-ticket` | `.claude/skills/shipping-a-ticket/SKILL.md` | yes, when work comes from a ticket tool (ClickUp, Jira, Linear, GitHub Issues) |
| `placing-changelog-fragments` | `.claude/skills/placing-changelog-fragments/SKILL.md` | optional — when the repo uses fragments (towncrier, changesets, `changelog.d/`) |
| `stacking-branches` | `.claude/skills/stacking-branches/SKILL.md` | optional — when the team stacks PRs (PRs based on other PRs) |
| review rules | `.claude/review-rules.md` | yes — the project-specific input of the global `reviewing-code` skill |

## Applies when / Skip when

- **Applies**: a git remote on GitHub/GitLab, a CI workflow, PRs in the history
  (`gh pr list --state merged --limit 20`).
- **Skip `syncing-branches`** for a solo repo pushing straight to the default branch.
- **Skip `shipping-a-ticket`** when no ticket tool is connected or referenced in branch names.
- **Skip `stacking-branches`** unless `gh pr list --state all --limit 50 --json baseRefName` shows
  PRs whose base is not the default branch.

## Detect

| Fact | Where to look | Confirm by running |
|---|---|---|
| Base branch | `gh repo view --json defaultBranchRef`; PR bases in history (`main`, `dev`, `develop`) | `gh pr list --state merged --limit 20 --json baseRefName` |
| Branch naming convention | `CONTRIBUTING.md`, recent branch names | `git branch -r --sort=-committerdate \| head -30` |
| Commit message convention | `CONTRIBUTING.md`, commitlint config, recent log | `git log --oneline -30` |
| Ticket tool and how ids appear | branch names, PR bodies, MCP servers connected | match ids across 10 recent PRs |
| PR template | `.github/pull_request_template.md`, `.gitlab/merge_request_templates/` | — |
| PR description language and shape | 5 recent merged PR bodies by the team | `gh pr list --state merged --limit 5 --json body` |
| Merge strategy (squash/rebase/merge) | repo settings | `gh api repos/{owner}/{repo} --jq '{squash:.allow_squash_merge,rebase:.allow_rebase_merge,merge:.allow_merge_commit}'` |
| CI jobs and their exact commands | `.github/workflows/*.yml` | list jobs; map each to a local command |
| CI "freshness" checks (generated files, migration order, version bumps, changelog) | CI steps that `git diff --exit-code` or validate | run each locally once |
| Migrations with ordered names (timestamps, sequence numbers) | `migrations/`, `alembic/versions`, `prisma/migrations` | list the newest 3 names on the base branch |
| Changelog fragments | `changelogs/`, `changelog.d/`, `.changeset/`, towncrier config | `git log --stat -20 \| grep -i changelog` |
| Review policy affecting force-push | `CONTRIBUTING.md` | — (ask if absent) |
| Stacked PRs | see Skip when | — |

## Ask

| Question | Recommended default |
|---|---|
| When is force-push allowed on a PR branch? | `--force-with-lease` while the PR is a draft and no colleague has reviewed or commented; after that, merge the base in and never force-push |
| Draft PRs by default? | Yes — the human flips it to ready |
| Language of PR descriptions? | the language of the team's recent PRs |
| Must the agent ask before pushing when a design choice is open? | Yes |

## Variables

| Variable | Filled by |
|---|---|
| `{{BASE}}` | base branch |
| `{{BRANCH_PATTERN}}` | e.g. `<type>/<slug>-#<ticket-id>` |
| `{{COMMIT_PATTERN}}` | e.g. `feat(scope): summary #<ticket-id>` |
| `{{CI_CORE}}` | local commands mirroring the main CI job |
| `{{CI_FRESHNESS}}` | per-area freshness checks: `<path changed> → <command>` |
| `{{MIGRATION_RULE}}` | how migrations are named/ordered and how to re-number, or empty |
| `{{REGEN_COMMANDS}}` | regeneration commands for generated files |
| `{{FORCE_PUSH_POLICY}}` | answer to the force-push question |
| `{{TICKET_TOOL}}` / `{{TICKET_FETCH}}` | the tool, and how the agent reads a ticket (MCP tool, CLI, `gh issue view`) |
| `{{PR_LANGUAGE}}`, `{{PR_TEMPLATE}}` | language; template path or empty |
| `{{FRAGMENT_RULE}}` | fragment folder(s), filename pattern, types, length limit |
| `{{TICKET_ID_RULE}}`, `{{REFINEMENT_NOTES}}` | where the ticket id lives; where local refinement notes live, or empty |
| `{{GENERATED_ARTIFACTS}}` | one row per generated artifact: path → what its diff must show |
| `{{RULES_POINTER}}`, `{{KNOWN_ABSTRACTIONS}}` | the coding-rules section to apply; enums/registries/helpers new code should reuse |
| `{{TEST_CONVENTIONS}}` | one row per observed test convention |

## Skeleton — `pre-pr`

````markdown
---
name: pre-pr
description: Use before opening or updating a PR — runs the CI gates locally (core, or full with the freshness checks) and reports the real result. Triggers include "pre-pr", "lance la CI en local", "est-ce que c'est prêt pour la PR".
---

# Pre-PR checks

Mode: `core` (default) mirrors the main CI job; `full` adds the freshness checks.

1. `git fetch origin {{BASE}}` so affected-detection and diffs are accurate.
2. Core: {{CI_CORE}}
3. Full only — for each area the branch touched (`git diff --name-only origin/{{BASE}}...HEAD`):
   {{CI_FRESHNESS}}
4. All green → say the branch is ready and stop.
5. Anything red → per failure: the relevant output (not the whole log), the root cause from the
   code, a concrete fix. Offer to apply mechanical fixes (format, stale generated file, missing
   fragment); ask before changing logic or tests.

Never claim a gate passed unless its command exited 0.
````

## Skeleton — `syncing-branches`

````markdown
---
name: syncing-branches
description: Use when bringing one branch up to date with {{BASE}} — "rebase sur {{BASE}}", "merge {{BASE}} et résous les conflits", or a PR gone red on conflicts. Covers rebase vs merge, when force-push is allowed, generated-file and migration conflicts.
---

# Syncing a branch with {{BASE}}

## Rebase or merge

{{FORCE_PUSH_POLICY}} Check whether a colleague has reviewed with
`gh pr view <n> --json isDraft,reviews,comments` and
`gh api repos/{owner}/{repo}/pulls/<n>/comments`, in its own step before any push. The author's own
review and bot comments do not count. When in doubt, merge: it is the recoverable option.

```bash
git fetch origin {{BASE}}
git rebase origin/{{BASE}} && git push --force-with-lease   # rewritable branch
git merge origin/{{BASE}} && git add -A && git commit && git push   # reviewed branch
```

`git add -A`, never `git commit -a`: `-a` silently omits new files.

## Conflicts

- Generated files: never hand-merge. Take either side, then {{REGEN_COMMANDS}}, commit the result.
[[if MIGRATION_RULE]]- Migrations: {{MIGRATION_RULE}} Re-number **last**, after every other conflict is resolved —
  the ordering is only correct as of the moment you sync.[[end]]
- Two tests sharing a call tail can collapse into one truncated test that still passes. Read both
  sides in full.
- After a rename on the branch, grep the **new** code the base brought in for the old name, with
  word boundaries (`grep -nE "\bOldName\b"`).

## CI still red after the merge

Do not keep patching a bad merge: abort, re-fetch, redo it from a confirmed-current base. A PR in a
conflicted state runs **no** CI — check `mergeable` before interpreting red.
````

## Skeleton — `shipping-a-ticket`

Built from a long-running "dev a ticket end-to-end" skill. Keep the steps; fill the tools.

````markdown
---
name: shipping-a-ticket
description: Use when developing a refined {{TICKET_TOOL}} ticket end-to-end — fetch it and its subtasks, implement each on its own branch, run the local gates, self-review, and open draft PRs in dependency order. Triggers include "dev la tâche X", "développe X", "implémente ce ticket". Not for refining a ticket and not for reviewing an existing PR.
---

# Shipping a ticket

**Unit of work = one ticket (or subtask) = one branch = one draft PR.** Never reuse a parent id
across several branches.

1. **Fetch the tree** — {{TICKET_FETCH}} for the ticket, each subtask, their dependencies and
   comments. The description is the spec; a comment matters only when it clearly overrides it.
   Announce what was loaded.
2. **Order the work** — blocking dependencies first, then explicit sequencing in descriptions, then
   the tool's order. Skip done/in-review items and items blocked outside the tree; say so. Show the
   plan before starting.
3. **Per unit:**
   - *Understand* — locate the real code, confirm the description matches it. Ask only when
     genuinely blocked (a contradiction, a missing business rule, a decisive fork).
   - *Branch* — `{{BRANCH_PATTERN}}` with the unit's own id, from `origin/{{BASE}}`, or from the
     previous unit's branch when it depends on it (stack; PR targets that branch).
   - *Implement* — follow the agent rules file; reuse existing types and vocabulary before adding
     new ones; update tests with any behaviour change; regenerate generated files.
     [[if FRAGMENT_RULE]]Add the changelog fragment now (`placing-changelog-fragments`).[[end]]
   - *Verify* — run `pre-pr` until every gate is green. Never open a PR on red.
   - *Self-review* — run `reviewing-code` in `full` mode on the branch, in a fresh subagent so the
     author is not its own reviewer. Fix 🔴 and obvious 🟡 findings, re-run `pre-pr` if code
     changed; **stop and discuss every "À trancher" item with the user before pushing**.
   - *Open* — commit (`{{COMMIT_PATTERN}}`), push, reuse an existing PR if any, else
     `gh pr create --draft`. Description in {{PR_LANGUAGE}}: context + ticket link by name, a
     diagram of the flow or data shape before any prose, design choices with their why, files per
     layer; no test/gate narration, no "next steps"; [[if PR_TEMPLATE]]keep the checklist of
     `{{PR_TEMPLATE}}`.[[end]] Report the PR link.
   - *Release* — detach the worktree from the branch so the user can check it out.
4. **Wrap up** — a table: unit | branch | PR | base. List skipped items and open questions. Do not
   change ticket statuses unless asked.
````


## Skeleton — `placing-changelog-fragments` (optional)

````markdown
---
name: placing-changelog-fragments
description: Use before committing a change to a package of this repo, or when asked to add a changelog entry — creates the fragment in the right folder with the right name and length.
---

# Changelog fragments

{{FRAGMENT_RULE}}

- One fragment per touched package per PR; update it on follow-up commits instead of adding a second.
- One line, in English unless the repo says otherwise; user-facing types address the product user
  (no symbol names), internal types address a developer.
- Never in a repo-root folder when packages have their own.
````

## Skeleton — `stacking-branches` (optional)

Generate only when the team stacks PRs. Core rules to include, all proven in practice:

- Rewrite a branch only while its PR is a draft without colleague review; read that state in its
  own step before any amend/force-push.
- Tag every branch before a restack (`git tag backup/<b>-pre-restack <b>`).
- Rebase the whole chain from the tip with `git rebase --update-refs --onto <new-base> <old-base-tip> <tip>`.
  A ref checked out in another worktree is **silently not moved**.
- Rebasing one branch: the upstream is always **its parent's old tip**; passing its own tip drops
  its commit while printing "Successfully rebased".
- After a parent is squash-merged, the child carries a duplicate patch: compare `git patch-id`
  before choosing merge or rebase.
- After every step verify per ref: differs from its parent, is an ancestor of the tip, commit count
  matches, `git diff <old-tip> <branch>` is empty.
- Gates at every branch tip, not only the top; verify committed content (`git show <sha>:<path>`),
  not the working tree.
- One worktree per stack; never touch the main checkout the user is testing from.

## Skeleton — `.claude/review-rules.md`

Read by the global `reviewing-code` skill. Not a skill itself: no frontmatter. Only what the
project's code and docs establish; drop an empty section.

````markdown
# Review rules — <project>

## Base and ticket
- Base branch: `{{BASE}}`. Stacked branches are reviewed against their parent branch.
- Ticket id: {{TICKET_ID_RULE}} (e.g. the `#<id>` suffix of the branch and commit messages).
- Load it with {{TICKET_FETCH}}, with its parent and siblings. {{REFINEMENT_NOTES}}

## Generated artifacts — read the diff only
| Artifact | What its diff must show |
|---|---|
| {{GENERATED_ARTIFACTS}} |

## Project rules to enforce
- Coding rules: {{RULES_POINTER}} (e.g. `.claude/CLAUDE.md` §3) — apply the whole section.
- Known abstractions to converge on: {{KNOWN_ABSTRACTIONS}}

## Test conventions
| Check | Flag when | Fix |
|---|---|---|
| {{TEST_CONVENTIONS}} |
````

Fill `{{TEST_CONVENTIONS}}` only from conventions observed in at least three existing test files
(or written in the rules file); `{{KNOWN_ABSTRACTIONS}}` from enums/registries/helpers that recent
reviews or the rules file point to.

## Prove

1. Run every `pre-pr` command on the current branch; all exit codes recorded.
2. In a throwaway clone: create a branch, make a trivial commit, run the `syncing-branches` rebase
   recipe against `origin/{{BASE}}`, delete the clone.
3. `shipping-a-ticket`: fetch one real ticket with `{{TICKET_FETCH}}` and print its title and
   subtasks — proves the ticket access path. Do not implement anything.
4. `.claude/review-rules.md`: run `reviewing-code` in `quick` mode on the current branch; it must
   read the file and name the right base.
5. Fragment rule: build a fragment name for a fake id and check the folder exists and matches the
   last merged fragments.

## Lessons baked in

- **Review status, not authorship, decides force-push.** A colleague's comment turns a branch into
  shared history.
- **`git commit -a` omits new files** — the classic way a migration or fragment goes missing.
- **A conflicted PR runs zero CI**: red-and-conflicted tells you nothing.
- **Migration order is only valid at sync time** — re-number last.
- **Self-review before push, discussion before push.** Pushing first makes a choice look settled
  and turns the discussion into rework.
- **PR descriptions that narrate tests and gates are noise**: CI says it. A diagram says more than
  paragraphs.
- **Releasing the branch from the agent's worktree** is what lets the user check it out locally.
