# Template — runtime verification

The generation procedure (interview, isolation probes, proving run) lives in the
`creating-verification-skills` skill. This template holds what it fills: the skeletons and the
detection signals `init-skills` uses to decide whether a surface deserves a verifying skill.

## Produces

| Skill | Path | Required |
|---|---|---|
| `verifying-<surface>` | `.claude/skills/verifying-<surface>/SKILL.md` + `features/` + `scripts/doctor.*` | one per primary surface that unit tests cannot prove (usually 1 to 3 per project) |

## Applies when / Skip when

- **Applies**: a runnable service — an HTTP server (FastAPI, Express, Spring, Rails…), a
  worker/job engine (Airflow, Celery, queues), serverless handlers, a CLI with side effects — **and**
  a way to observe its result (a database, a bucket, logs, an HTTP response).
- **Skip** a pure library (its tests are the proof), or a surface that cannot be started locally at
  all. Say which, and why.
- **Cost gate**: a surface that calls paid APIs (LLM, SMS, payments) gets its skill, but with an
  explicit "costs money — ask first" section, and its proving run needs the user's agreement.

## Detect

| Fact | Where to look | Confirm by running |
|---|---|---|
| Surfaces | `docker-compose*.yml` services, `Dockerfile`s, app entrypoints, `serverless.yml`, DAG folders | list them; pick the primary ones with the user |
| Launch command per surface | task runner `dev`/`serve` targets, compose, `CMD` | start it; time the cold boot; note the ready signal |
| Ports and hostnames | compose, settings, `.env.example` | from the agent's shell: `localhost` vs compose hostname |
| Boot side effects (migrations, seeds) | entrypoint scripts, startup hooks | read the boot log |
| Auth for local calls | auth middleware, dev users, seed scripts, token helpers | obtain one token and call one protected route |
| Existing drive helpers | `scripts/`, generated API client, admin CLI | call one |
| Observable state | DB client in the container, `psql`/`mongosh`/`redis-cli`, bucket CLI, job UI API | read one record |
| Isolation | settings loader (`load_dotenv(override=…)`), DB name config | start a second instance on another DB and check which DB it writes |

## Variables

| Variable | Filled by |
|---|---|
| `{{SURFACE}}` | short kebab name (`backend-api`, `ai-flows`, `worker`) |
| `{{SERVICE_DESC}}` | one line: what it is and what it talks to |
| `{{LAUNCH}}` / `{{READY_SIGNAL}}` / `{{TEARDOWN}}` | start command, how to know it is ready, how to stop what you started |
| `{{BASE_URL}}` | base URL as reachable from the agent's shell |
| `{{AUTH}}` | how to get credentials for a local call |
| `{{DB_READ}}` | how to read the resulting state |
| `{{ISOLATION}}` | the proven isolation model (separate worktree / DB name / container) |
| `{{COST}}` | cost note, or empty |

## Skeleton — `SKILL.md`

````markdown
---
name: verifying-{{SURFACE}}
description: Use to prove {{SERVICE_DESC}} actually works at runtime — after a change to its routes, handlers, persistence or config, when unit tests pass but something is wrong in the app, or before claiming a feature done. Launches it for real, drives it the way the app does, and reads the resulting state.
---

# Verifying {{SURFACE}}

[[if COST]]**Cost.** {{COST}} Ask the user before any drive that triggers it; prefer the free
negative cases.[[end]]

## Isolation

{{ISOLATION}} **Never drive an instance this run did not start.**

## Launch

```bash
{{LAUNCH}}
```

Ready when: {{READY_SIGNAL}}. Record the PID you started.

## Doctor — run first, and again after any surprise

```bash
<this-skill-dir>/scripts/doctor.<ext>
```

Exit 0 means: process up, the expected database, dependencies reachable from `{{BASE_URL}}`.

## Drive

Auth: {{AUTH}}. Then follow the feature file for what you are proving — `features/README.md` lists
them. Every entry point a feature lists is driven, not only the convenient one.

## Evidence

- The request, the status code and the body.
- A second, independent read of the stored state: {{DB_READ}}
- Side effects (records written, objects stored, events emitted) alongside the response.
- Which feature id and entry point produced each artifact.
- A path that could not be reached: the command attempted and the unmet prerequisite. **Never report
  a skipped entry point as verified through another.**

## Cleanup

```bash
{{TEARDOWN}}
```

Kill what you started (by PID), never by process name. Cleanup never deletes evidence.
````

## Skeleton — `features/README.md` and one feature file

Follow `creating-verification-skills/references/feature-map-contract.md` exactly: the README has
*Baseline preconditions*, *Driving conventions*, *Proof and skip reporting*, *Features*; each feature
file has *Sub-features*, *How to get to it (user POV)*, *Driving it with <harness>*, *Gotchas*.

## Skeleton — `scripts/doctor`

A read-only script, exit 0 or 1 with one line per check:

1. the port answers at `{{BASE_URL}}` (a health route if the service has one);
2. the instance is connected to the expected database name (read it from a debug route, a log line,
   or the settings the process was started with — never assume it);
3. each dependency answers on the hostname the **service** uses (compose hostname in a container);
4. the version/commit served matches the checkout when the service exposes it.

## Prove

Delegated to `creating-verification-skills` §4: launch, doctor, drive **one** feature, capture
evidence, clean up, confirm the evidence survived. A skill never executed is a draft.

## Lessons baked in

- **Unit tests and a clean boot are not proof.** The bugs that matter appear only when the real path
  is driven and the stored state is read back.
- **Env vars may not isolate** (`.env` loaded with override); prove isolation by running.
- **`localhost` lies in containers**; use the hostname the service itself uses.
- **A doctor first** saves the hour spent debugging a "bug" that is a dead dependency.
- **Soft deletes** make raw DB counts and API counts differ legitimately.
- **Paid surfaces** get proven through their free failure paths first.
