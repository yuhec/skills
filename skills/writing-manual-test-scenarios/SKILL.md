---
name: writing-manual-test-scenarios
description: Use to write short manual end-to-end test scenarios for a branch or PR — the simple happy path, the regression checks on areas the diff touched indirectly, and the tricky cases that prove the edge behaviour. Triggers include "scénarios de test manuels", "comment je teste cette PR", "plan de recette", "qu'est-ce que je dois cliquer pour vérifier", "test plan for this PR", "QA scenarios". Not for writing automated tests and not for running the checks against a live service (use the project's verifying-* skill).
---

# Manual e2e test scenarios for a PR

Input: a branch or PR. If none is given, use the current branch.

The output is a checklist a human runs in the app in about fifteen minutes. Every scenario is
something they can click through and see pass or fail — never "check that the code handles X".

## Step 1 — Read the real diff

- Base: the PR base if a PR exists (`gh pr view <branch> --json baseRefName`), otherwise the
  repo's default branch.
- `git diff $(git merge-base origin/<base> <branch>)..<branch>` and read it. Scenarios built from
  the conversation or the PR title miss what was actually pushed.
- Read the ticket when the branch name carries an id: the acceptance criteria are the happy path.

## Step 2 — Map each change to what a user sees

For every changed backend symbol, follow it outward until it reaches a screen:

```
changed function ─► caller(s) ─► API route ─► frontend service / API client ─► view/component ─► frontend route
```

- Find callers with `grep -rn <symbol>` across the source tree — include callers outside the diff.
  **Those callers are the impacted areas**: the diff did not touch them, but their behaviour now
  depends on code that changed.
- A change with no path to a screen (migration, background job, scheduled flow, script) gets its
  observable effect instead: the record in the database, the log line, the emitted event, the
  result visible on the next screen that reads it.
- Frontend-only change: the route and component are the entry point; list every other component
  that imports the changed component, hook/composable or store.

## Step 3 — Write the three sections

**1. Happy path** — 1 or 2 scenarios. The feature as the ticket describes it, with the simplest
realistic data. If this fails, nothing else is worth running.

**2. Still works** — 2 to 5 scenarios, one per impacted area from Step 2. Each exercises the
existing feature the way it was used before the PR and expects the same result as before. Name
why it is at risk in one line (*shares `compare_values` with the new enum path*).

**3. Tricky cases** — 3 to 6 scenarios. Derive each from something in the diff, never from a
generic checklist. Look for:

| In the diff | Scenario |
|---|---|
| a new `if`, `match` arm or early return | the input that takes the branch *and* the one just outside it |
| an optional / nullable field | absent, empty (`""`, `[]`), and present |
| a list or a multiplicity (single vs multiple) | zero, one, several items |
| a limit, threshold or comparison | exactly at the boundary, and one past it |
| a new exception or HTTP 4xx | the input that triggers it, and the message the user sees |
| a changed data shape or a migration | an entity created **before** the PR, opened and edited after it |
| a type/mode/enum dispatch | one scenario per variant the UI lets the user pick |
| a save path | save, reload the page, the value is still there |

Drop a row that the diff gives no reason to test. A tricky case with no line of the diff behind it
is noise.

## Scenario format

Numbered across sections, each fitting in a few lines:

```
### 3. Enum compared to an absent value
Why: new `None` branch in `compare_values`
Setup: category "Shoes" with attribute `color` (enum), one product with no color
Steps:
  1. /automation → new rule "color equals red" on "Shoes"
  2. Run it
Expected: the product without color is not matched, no error toast
```

- **Setup** names the exact data to have or create. A scenario whose setup the tester has to
  invent will not be run.
- **Steps** are UI actions or one HTTP call, five at most. Split a longer one.
- **Expected** is one observable result: text on screen, a value after reload, an HTTP status, a
  field in the database. Never "works correctly".
- Every symbol, route and screen named is real — taken from the diff or the router, not invented.

## Rules

- Answer in chat, in the user's language. The whole list fits on one or two screens: cut a
  scenario rather than shorten every scenario.
- End with a one-line **Not covered** listing what these scenarios cannot reach (a job only a
  scheduler triggers, an environment-specific setting) so the gap is explicit.
- Write the scenarios; do not run them. To execute the API or DB ones, hand them to the project's
  `verifying-*` skill when it has one.
