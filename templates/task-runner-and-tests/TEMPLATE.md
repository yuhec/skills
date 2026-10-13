# Template — task runner and tests

## Produces

| Skill | Path | Required |
|---|---|---|
| `running-tasks` | `.claude/skills/running-tasks/SKILL.md` | yes, when the project has a task runner or package scripts |
| `testing` | `.claude/skills/testing/SKILL.md` | yes, when the project has a test suite |
| `writing-tests` | `.claude/skills/writing-tests/SKILL.md` | optional — only when the existing tests follow conventions an agent would not guess (naming, structure, factories, mocking style) |

## Applies when / Skip when

- **Applies**: any of `moon.yml`/`.moon/`, `nx.json`, `turbo.json`, `Makefile`, `justfile`,
  `Taskfile.yml`, `package.json` `scripts`, `pyproject.toml` (`[tool.poe]`, `[tool.hatch]`, uv
  scripts), `tox.ini`/`noxfile.py`, `Cargo.toml`, `go.mod`, `build.gradle`/`pom.xml`.
- **Skip `running-tasks`** when there is a single obvious command per gate and nothing can go wrong
  by calling the tool directly (a tiny single-package repo). Put the commands in the agent rules
  file instead.
- **Skip `testing`** when there are no tests. Say so — it is a finding, not a gap to paper over.

## Detect

| Fact | Where to look | Confirm by running |
|---|---|---|
| Task runner and how to invoke it | files above; CI workflow (`.github/workflows/*.yml`, `.gitlab-ci.yml`) — **CI is the ground truth for what a gate is** | `<runner> --help`, list projects/tasks (`moon query projects`, `nx show projects`, `make -qp`, `npm run`) |
| Projects/packages and their ids | workspace config, folders with their own manifest | the runner's project listing |
| Gate commands: lint, format(-check), typecheck, test, build | CI steps; runner task definitions; package scripts | run each once on a clean tree; note duration and exit code |
| A fast local gate (impacted tests, `check` aggregate, `--affected`) | runner config, pytest plugins (`pytest-testmon`, `pytest-xdist`), `vitest --changed`, `jest --onlyChanged`, `nx affected` | run it twice with nothing changed: the 2nd must be near-instant, and must **not** report a full-suite green |
| Runner caching | `cache: false`/inputs/outputs in task config, `turbo.json` `outputs` | run a gate twice; a cached hit must say so. Check that the inputs include what actually matters |
| Package manager and lockfile discipline | `uv.lock`, `poetry.lock`, `package-lock.json`, `pnpm-lock.yaml`, `Cargo.lock` | `uv sync --frozen` / `npm ci` / `pnpm i --frozen-lockfile` succeeds |
| Test frameworks, markers, slow/integration split | `pyproject.toml` `[tool.pytest]`, `vitest.config.*`, `jest.config.*`, `conftest.py`, markers used | collect the suite; count tests; run one file |
| Test infrastructure: DB, containers, in-memory servers, env vars | fixtures, `docker-compose*.yml`, `.env.example`, testcontainers | run one test touching the DB from a fresh shell |
| Gitignored files a fresh checkout needs (`.env`, certs, generated code) | `.gitignore` vs files referenced by settings; `.env.example` | run the test suite in a fresh worktree; read the first failure |
| Worktree setup script | `scripts/`, `.claude/scripts/`, `Makefile` targets | create a throwaway worktree with it and run the fast gate |
| Generated artifacts (OpenAPI schema, API clients, protobuf, ORM types) and the command that regenerates them | CI "freshness" steps, `scripts/generate*`, `package.json` scripts | regenerate on a clean tree: `git diff --exit-code` must stay clean |
| Typecheck tool and whether every project has a task for it | runner config; `mypy`/`pyright`/`ty`/`tsc`/`vue-tsc` | run it per project; list projects without a task |
| Test conventions (for `writing-tests`) | 5–10 recent test files, test helpers/factories folder, the agent rules file | — (read, then quote real examples) |

## Ask

| Question | Recommended default |
|---|---|
| Must every gate go through the task runner, even for a one-off? | Yes, when CI uses the runner — it keeps local and CI identical |
| Which gate is "enough" while iterating, and which once before the PR? | fast/impacted gate while iterating; full suite once per branch tip before the PR |
| Are `slow`/`integration` tests excluded locally? | Excluded from the fast loop, always run by the full suite and CI |

## Variables

| Variable | Filled by |
|---|---|
| `{{RUNNER}}` | the task runner (`moon`, `nx`, `make`, `npm run`, `uv run`) |
| `{{RUN_ONE}}` / `{{RUN_ALL}}` | run a task for one project / for all, e.g. `moon run <project>:<task>` / `moon run :<task>` |
| `{{LIST_PROJECTS}}` / `{{LIST_TASKS}}` | listing commands |
| `{{GATE_LINT}}`, `{{GATE_FORMAT}}`, `{{GATE_TYPECHECK}}`, `{{GATE_TEST}}`, `{{GATE_BUILD}}` | the exact commands CI runs, expressed through the runner |
| `{{GATE_FAST}}` | the impacted/aggregate local gate, or empty |
| `{{GATE_FULL}}` | the full suite as CI runs it |
| `{{TEST_ONE}}` | how to run a single test by id for debugging |
| `{{NO_TASK_FALLBACK}}` | how to run a gate for a project with no task defined |
| `{{WORKTREE_SETUP}}` | worktree creation command, or empty |
| `{{FRESH_CHECKOUT_FILES}}` | gitignored files a new checkout needs |
| `{{REGEN_COMMANDS}}` | regeneration commands per generated artifact |
| `{{TEST_INFRA}}` | how tests reach their DB/services and the isolation caveat |

## Skeleton — `running-tasks`

````markdown
---
name: running-tasks
description: Use before running any lint, format, typecheck, test or build in this repo — whether you were asked to or decided to mid-task: every one goes through {{RUNNER}}, never the underlying tool directly. Also when a project id is rejected, a task graph needs inspecting, or a green result may have come from cache.
---

# Running tasks

CI runs every gate through {{RUNNER}}; run them the same way so a local green means a CI green.

| Action | Command |
|---|---|
| One task, one project | `{{RUN_ONE}}` |
| One task, all projects | `{{RUN_ALL}}` |
| List projects / tasks | `{{LIST_PROJECTS}}` / `{{LIST_TASKS}}` |
| Lint | `{{GATE_LINT}}` |
| Format | `{{GATE_FORMAT}}` |
| Typecheck | `{{GATE_TYPECHECK}}` |
| Build | `{{GATE_BUILD}}` |
[[if GATE_FAST]]| Fast local gate (iterate) | `{{GATE_FAST}}` |[[end]]

## Rules

- Run from the root of the checkout you are in — worktrees included.
- Never call the tool directly (`pytest`, `eslint`, `tsc`…) for a gate: the runner sets flags,
  rootdirs and env that the bare tool does not.
[[if NO_TASK_FALLBACK]]- A project with no task for a gate is the one exception: `{{NO_TASK_FALLBACK}}`.[[end]]
- A green from cache is only as good as the task's declared inputs. If you changed something the
  inputs do not list (a fixture, an env file, a generated file), force the run.
- `cmd | tail` reports `tail`'s exit code. Use `set -o pipefail` or read `${PIPESTATUS[0]}` before
  calling a piped gate green.
[[if REGEN_COMMANDS]]
## Generated artifacts

Never hand-edit or hand-merge these; regenerate and commit the result:

{{REGEN_COMMANDS}}
[[end]]
````

## Skeleton — `testing`

````markdown
---
name: testing
description: Use before running or debugging any test in this repo — whether you were asked to or decided to mid-task. Also when a run says `no tests ran`, finishes suspiciously fast, fails at collection in a fresh checkout, or a worktree starts cold.
---

# Testing

| Scope | Command |
|---|---|
| Full suite, as CI | `{{GATE_FULL}}` |
[[if GATE_FAST]]| Impacted tests only (iterate) | `{{GATE_FAST}}` |[[end]]
| One test, to debug | `{{TEST_ONE}}` |

## Reading the result

[[if GATE_FAST]]- `no tests ran` / `0 selected` from the fast gate means *nothing impacted is covered* — it is
  **not** a green suite. Never report it as one.
- A test named in a brief is proven by running it by id through the full command, which does not
  filter by impact.
- What the impact tracker cannot see (data fixtures, env vars, generated files) selects nothing
  when it changes.[[end]]
- Run `{{GATE_FULL}}` once per branch tip before opening a PR, in the foreground, with no other
  test run on the same checkout.

## Test infrastructure

{{TEST_INFRA}}

[[if FRESH_CHECKOUT_FILES]]
## Fresh checkouts and worktrees

A new checkout lacks gitignored files: {{FRESH_CHECKOUT_FILES}}. Without them the suite fails at
collection with an error that reads like a regression. [[if WORKTREE_SETUP]]Create worktrees with
`{{WORKTREE_SETUP}}`, which copies them.[[end]]
[[end]]

## Debugging a failure

1. Collection error on settings/config → missing gitignored file (above), not a regression.
2. Re-run the single failing test verbosely with `{{TEST_ONE}}`.
3. Read the fixtures it depends on before changing the test.
4. Never edit an existing test just to make a fix pass without understanding why it broke.
````

## Skeleton — `writing-tests` (optional)

Generate only from conventions **observed in at least three existing test files**, quoting one real
example per rule. Cover: file/class organisation, test naming pattern, body structure
(arrange/act/assert), where shared builders/factories live, the mocking primitive, markers
(`slow`, `integration`), and what not to test (private methods). If the tests have no consistent
convention, do not generate this skill — say so.

## Prove

1. Run every command written into the generated skills once, from the repo root. Record exit code
   and duration.
2. Fast gate: run it twice with no change → second run selects nothing and says so; touch one
   source file → it selects that file's tests.
3. Create a throwaway worktree the documented way and run the fast gate there; delete the worktree.
4. Regenerate each generated artifact on a clean tree → `git diff --exit-code` is clean.

## Lessons baked in

- **CI defines the gate, not the README.** Commands copied from docs drift; commands copied from the
  CI workflow are what decides the merge.
- **"Go through the runner" needs a reason in the skill**, or agents call the tool directly the
  first time it is faster. The usual real reasons: rootdir/config flags, cache keys, env loading.
- **An impacted-test loop's empty result is the most common false green.** Say so in the skill.
- **Flags that silently disable impact selection** (e.g. `-k`, `-m`, `--lf`, coverage with
  `pytest-testmon`) turn a fast loop back into a full run, or the reverse. Document the ones that
  apply to the detected tool.
- **A fresh worktree fails at collection** when gitignored config is missing; the failure reads like
  a regression. A setup script that copies those files saves an hour per occurrence.
- **Piped exit codes lie.** `pytest | tail` is green whatever pytest did.
- **Generated files are never hand-merged**: take either side, regenerate, commit.
