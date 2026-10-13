# Feature map contract

A feature map lives at `.claude/skills/verifying-<surface>/features/`: a `README.md` index plus one
file per user-facing feature. It is the maintained source for what "this service works" means.

Keep implementation detail out of it. Name only user paths, stable handles, required state, exact
commands, and observable proof.

## README.md

Four sections, in this order.

### Baseline preconditions
The state every recipe assumes: which command launched the service, on which port, against which
database, what seed data exists, which helper scripts are on `PATH`, and the doctor command that
must pass first. End with the rule: **never drive an instance this run did not start.**

### Driving conventions
How to address things. Prefer stable handles (route paths, document ids returned by the API,
Airflow `dag_id`) over positional or derived ones. Say which helper wraps each kind of action. Say
what to restore after a mutation, and that cleanup never removes proof artifacts.

### Proof and skip reporting
- Capture the action and the resulting state, not only the end state.
- API proof includes the request, the status code, and the response body.
- Mutation proof includes a second, independent read of the stored value.
- Record which feature id and which entry point produced each artifact.
- Report an unreachable path with the command attempted and the unmet precondition.
- **Never report a skipped entry point as verified through a different path.**

### Features
One line per feature file, linking it and saying what it covers.

## One file per feature

An H1 title, one paragraph of user-visible behaviour, then exactly four H2 sections in this order.

1. **`Sub-features`** — short ids with one line each. Ids are stable; other files and reports cite
   them.
2. **`How to get to it (user POV)`** — every entry point, not just the convenient one.
3. **`Driving it with <harness>`** — starts with `Preconditions:`, then labelled bullets pairing
   each user action with the exact command and the observable result.
4. **`Gotchas`** — traps that waste or invalidate a run.

## Example of one driving bullet

> - **Create from the API.** Post the new category. Run
>   `python scripts/verify/drive.py post /v1/config/categories --json fixtures/category.json`.
>   Status `201` and the body carries a server-assigned `id`; the ids in the request are ignored.

The bullet names the user action, gives a command that can be pasted, and states an observable
result precise enough to fail on.

## What invalidates a map entry

- It describes behaviour the service no longer has → doc drift, fix the map.
- The harness cannot drive a working behaviour → harness gap, fix the harness.
- The behaviour is genuinely broken → product gap. Report it. **Do not paper over it in the map.**
