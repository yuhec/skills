# Tooling lens

Read the session transcript at `<TRANSCRIPT_PATH>`. You are looking for **what a mechanism would
have caught**, not for what someone should have remembered.

For each candidate, answer:

- **The failure**: what broke, was re-run, or was discovered late.
- **The mechanism that would have caught it**, named concretely: a type that makes the state
  unrepresentable, a domain exception, a boot-time guard, a lint rule, a task-runner input, a test
  in the suite, a script.
- **Where it would live**: a real path in this repo.
- **What it costs** to build, roughly.

Hunt for:

- a command re-run several times with different flags before it did what was wanted
- a gate that went green while something was broken (a cached task, a narrow test selection,
  `no tests ran`, a piped exit code)
- a manual sequence performed more than twice
- a fact rediscovered mid-session that a check could assert instead
- an environment surprise: a missing binary, a service not on `localhost`, a path that differs in a
  worktree, a gitignored file missing from a fresh checkout

Rank by (times it would fire) ÷ (cost to build). A mechanism that fires once is not worth building;
say so rather than proposing it.

Return one block per finding: failure / mechanism / path / cost / rank. At most 6.
