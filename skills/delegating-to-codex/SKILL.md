---
name: delegating-to-codex
description: Use when delegating a coding, review, or diagnosis task to Codex, or when unsure how to reach "codex luna" / "codex sol", which Codex models exist, or how to pin Codex to a worktree.
---

# Delegating to Codex

**Hand back the command first, then ask.** Fill the unknowns with obvious placeholders
(`<worktree>`, `<ticket-id>`, `<scope>`) and put your questions after it. A delegation that never
starts costs more than one carrying a placeholder.

## Overview

Two Codex models are used, always passed explicitly: a **small** one for well-specified work (one
project, up to five files) and a **large** one for everything else: several layers, a refactor, or
judgment left to Codex. As of 2026-09 they are `gpt-6-luna` (small, "luna") and `gpt-6-sol` (large,
"sol") — **re-read `~/.codex/models_cache.json` before relying on an id, never take one from
memory.** Implementation runs through `codex exec` in approve-for-me mode with the sandbox opened to
the project's toolchain; the Claude Code `codex` plugin, when installed, serves read-only review and
diagnosis only.

## Quick reference

| Want | Do |
|---|---|
| Implementation | `codex exec -C <worktree> -m <small-or-large> --approve-for-me -c 'sandbox_workspace_write.writable_roots=[<toolchain dirs>]' -c sandbox_workspace_write.network_access=true -o <report> "<brief>" < /dev/null` |
| Read-only run beside other agents (a review lens) | `codex exec -C <dir> -m <large> -s read-only -o <file> "<prompt>" < /dev/null` |
| Diagnosis via the plugin, read-only | `node "$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/ \| sort -V \| tail -1)scripts/codex-companion.mjs" task --cwd <worktree> --model <large> --prompt-file </abs/brief.md>` (no `--write`) |
| Code review via the plugin | `... codex-companion.mjs review --cwd <worktree> --base origin/<base-branch>` |
| Code review, user-driven | the user runs `/codex:review` or `/codex:adversarial-review` — plugin commands the model cannot invoke |
| Readiness / auth | the user runs `/codex:setup` |
| Machine-readable output | `--json`, `-o <file>`, `--output-schema <file>` |

`<toolchain dirs>` are the directories the project's tools write to outside the checkout on every
call — for example `~/.proto`, `~/.moon`, `~/.cache/uv`, a shared venv root, `~/.npm`. Find them
once per project (run the gate under `codex exec` and read what the sandbox refused) and record them
in the project's own delegation notes.

## Key facts

- When `-m` is unset, a run uses `model =` in `~/.codex/config.toml` (`grep '^model' ~/.codex/config.toml`). Always pass `-m`.
- `codex --version` reports the CLI version; `codex update` performs a global upgrade, it is not a dry check.
- `codex exec` defaults: `approval: on-request`, `sandbox: workspace-write [workdir, /tmp, $TMPDIR]`.
  It reads stdin even when the prompt is an argument: without `< /dev/null` it waits forever on an
  open stdin (background shell, subagent). **Always end the command with `< /dev/null`.**

## Why approve-for-me with an opened sandbox

`--approve-for-me` runs Codex in the `workspace-write` sandbox rooted at `-C`, and sends any command
that asks to leave it to Codex's automatic approval classifier. That sandbox alone refuses every
write outside the working directory and every socket, while most toolchains write bookkeeping files
outside the checkout and some tests talk to a database container. The two `-c` options open exactly
that: those directories as writable roots, and network access. The project's fast gate then runs
without an escalation, and a write anywhere else still stops at the sandbox. The plugin cannot be
used for implementation: its `task` command offers only `read-only` or `workspace-write` with
approvals disabled, so nothing can escalate.

## Pinning Codex to a tree it may actually touch

A written instruction to use a particular worktree is not reliable on its own. **Pin the cwd** with
`-C` (CLI) or `--cwd` (plugin). Pass the worktree that already holds the branch or stack; create one
only when none exists, with the project's worktree setup script if it has one (it usually copies
gitignored `.env` files and warms caches). State the venv / node_modules path in the brief too, and
say explicitly that the main checkout is off-limits if other sessions share it.

## Watching a background job — the state file lies

| Signal | Reality |
|---|---|
| job `.json` `status: "running"` | Can stay `running` after the process is gone. Never trust it alone. |
| job `.json` `pid` | Can be the launcher (already dead). Find the live Codex by its command line (`pgrep -fl codex`, or `/proc/*/cmdline` where `ps` is missing). |
| `.log` mtime | The reliable liveness signal: a long silence means Codex is blocked inside a command, not thinking. |
| `timeout Ns <cmd>` inside Codex | Does not reliably kill a sandboxed command. Budget for the hang. |

To stop a stuck job: kill the innermost Codex/sandbox processes with `TERM`, then `KILL` survivors.

## Checks in a delegated brief

Keep the repeated checks scoped to the touched projects, then run the wider gates once before
pushing.

| Who | What | When |
|---|---|---|
| Codex, in its loop | the project's fast gate (lint + impacted tests) on the touched projects | every iteration |
| You, in the main loop | the full test suite and the typecheck | once, before the push |
| CI | everything | on the PR |

Never ask Codex for the full suite at the end of each run. **Do not trust a delegated green.** A
check limited to the files Codex touched can miss regressions elsewhere; run the project gates
yourself before reporting results. Keep the brief's scope clear, include measurements already
gathered, and match `-c model_reasoning_effort=` to the work.

## Common mistakes

- Reading `model: sonnet` on the plugin's rescue agent as the Codex model: that is the wrapper's model.
- Handing a "look but don't touch" task to the plugin without saying read-only: it defaults to write-capable.
- Delegating implementation through the plugin: its sandbox cannot escalate and breaks the toolchain.
- Dropping the two `-c` options: every gate then fails inside the sandbox or waits on an escalation.
- Running `codex update` to check the version: it upgrades the CLI.
- Telling Codex in prose to stay in a directory and assuming it obeys: pin it with `-C` / `--cwd`.
