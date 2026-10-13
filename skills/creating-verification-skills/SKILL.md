---
name: creating-verification-skills
description: Use when a project or service has no scripted way to prove its behaviour at runtime — "on n'a aucun moyen de vérifier que ça marche vraiment", onboarding a new service, or when unit tests keep passing while the feature is broken. Generates a project-local verifying-<surface> skill with a feature map, and proves it once. For keeping an existing one honest, use maintaining-verification-skills.
---

# Creating a verification skill

## Why this skill exists

Most repos' checks stop at unit tests, typecheck and lint. Passing unit tests and a passing boot are
not proof a feature works end to end — bugs that slip past both surface only when something drives
the real thing. Telling an agent to do that E2E drill in prose is not enough: an instruction with no
tooling behind it gets skipped.

This skill generates the tooling: a project-local skill that launches the real thing, drives it the
way the app does, and captures evidence. The skeleton to fill is
`<skills-repo>/templates/verification/TEMPLATE.md` (resolve `<skills-repo>` from this skill's own
directory: it is two levels up).

**Write the output for the next agent, not for a human.** It will be read cold, mid-task, by an
agent that has never seen the service.

## 0. Check nothing already covers it

```bash
ls -d .claude/skills/verifying-* .agents/skills/verifying-* 2>/dev/null
```

Read the `description` of each hit. If one already covers this service and surface, you are in
`maintaining-verification-skills`, not here — generating a second one splits the feature map and
both halves rot. Generate only for a surface no existing skill claims.

**If driving the target service costs money** (a paid LLM or third-party API behind it), say so and
get agreement before §4's proving run, and write that cost gate into the generated skill.

## 1. Interview the repo, not the user

Answer these from the code. Only ask what you cannot observe.

- **Surface.** What is actually exercised? An HTTP API plus its database, a workflow/DAG engine, a
  serverless handler, a CLI, a browser UI. Pick one primary surface per generated skill and note the
  rest.
- **Run.** How does it start? Prefer the repo's own command (task runner `dev` target, compose
  service, the `Dockerfile` `CMD`, an `init.sh`). Note ports, the env file, whether boot runs
  migrations or seeds, and how long a cold boot takes.
- **Drive.** How can an agent exercise it programmatically? **Existing helpers first.** Name them
  before you write anything: a `scripts/` client, an HTTP helper, a CLI, a repository class you can
  import, the generated API client. Only then fall back to a generic recipe (`curl`, `httpx`).
- **Auth.** How does a local run authenticate? A dev bypass, a seeded user, a token script. Never
  invent a bypass the service does not have; if there is no local path, say so.
- **Observe.** What evidence can be captured? HTTP status and body, a database record, a job run
  state, a log line, an exit code, an object in a bucket.
- **Isolate.** Can two instances run side by side? **Answer this by running something, not by
  reading the settings module.** See the traps below.

If the service does not boot as-is, fix that or report it precisely before generating. A skill
written against a broken base teaches wrong steps.

### Isolation traps to probe, not assume

- **`.env` loaded with override.** A settings module calling `load_dotenv(override=True)` silently
  clobbers an exported variable, so a second instance cannot be pointed at another database by
  environment alone. A probe under `python -c` can lie (no `__file__`, so `find_dotenv` falls back
  to the cwd) — probe with the real entrypoint. When env cannot isolate, the **tree** is the unit of
  isolation: a worktree whose own `.env` carries its own database name.
- **Container hostnames.** Inside a devcontainer, services are often reachable by compose hostname
  (`db:5432`, `mongodb:27017`), **not** on `localhost`. A doctor that probes `localhost` reports a
  healthy stack as down.
- **Test fixtures that drop databases.** If the test suite tears down a database by fixed name, never
  point it at the live instance while a test run may be in flight.

The generated skill states its isolation model explicitly and never quietly assumes a scratch
database it does not have.

## 2. Generate the skill

Write `.claude/skills/verifying-<surface>/SKILL.md` from the template, with frontmatter (`name`, and
a `description` naming the service, the surface, and when to reach for it — without frontmatter it
never registers) and these sections, each grounded in what the interview found. **No placeholders
left.**

- **Launch.** The exact command, and how to tell it is ready — a port answering, a specific
  endpoint, a log line. Include teardown. Note anything boot does beyond starting the server
  (migrations, seeding) and how a failure there presents.
- **Doctor.** One read-only script answering "is this instance worth driving?": process up, expected
  version, the right database, dependencies reachable. An agent runs it first whenever anything
  looks off.
- **Drive.** The recipe with real routes, real ids and real commands from this repo. Reuse the
  helpers the interview found instead of writing a new client.
- **Evidence.** What to capture and where it goes, plus the proof standards below.
- **Cleanup.** How to tear down what the run created. **Never kill by process name; kill what you
  started** (record the PID). Cleanup removes instances and scratch state, never the evidence.
- **Helpers.** Any script the skill ships is executable and its invocation appears in the skill
  body. A helper the reader has to reverse-engineer is not a helper.

### Proof standards to state in the generated skill

- Exercise the real user path, not an internal setter or a test-only entry point.
- Capture the action **and** the resulting state, not just the end state.
- Verify side effects — the record written, the object stored, the event logged — alongside the
  response.
- Mock only where a production boundary already isolates the external system.
- When the safe path is a dry run, verify what it actually skips by observing, not by trusting its
  name.
- Remember soft deletes: raw database counts and API counts legitimately differ.

## 3. Seed the feature map

Create `.claude/skills/verifying-<surface>/features/README.md` plus one file per user-facing
feature, starting with the 3 to 5 that matter. Follow `references/feature-map-contract.md` (in this
skill's directory). The map is the maintained source of truth: a proof that drives one convenient
entry point is incomplete when the map lists others.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive **one** mapped feature, capture
evidence, clean up. After cleanup, confirm the evidence still exists where the skill says it does —
a cleanup that eats its own proof fails this step.

Fix what fails, and run the cleanup after every failed attempt too, so broken tries do not strand
processes and ports.

**A generated skill that was never executed is a draft, not a deliverable. Say which it is.**

## 5. Point at the maintenance loop

Tell the user that `maintaining-verification-skills` keeps the map honest as the service changes.

## Provenance

Ported from `create-verification-skill` in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)
(Lauren Tan, MIT). The interview/generate/prove structure is theirs; the isolation traps and the
container-hostname rule come from real runs.
