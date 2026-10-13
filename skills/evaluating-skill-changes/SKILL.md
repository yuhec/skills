---
name: evaluating-skill-changes
description: Use to MEASURE whether an edit to a skill, command, agent or brief changes agent behaviour for the better, when the answer is worth several agent runs — "est-ce que ce skill sert vraiment ?", "compare les deux versions du skill", "mesure l'effet de cette modif", before promoting a local skill to the shared agent rules. Runs a blinded A/B with mixed Claude and Codex candidates and a judge that never sees which arm is which. NOT for proofreading or editing a skill, and not when only one version exists — just make the edit.
---

# Evaluating skill changes

## Why this skill exists

Nothing in a repo answers "did this edit make agents behave better?" A read-through, or a sense
that the new wording is clearer, is not a measurement — it does not catch a skill that reads well
on the page but that agents route around, misapply, or drop under pressure.

The question matters most exactly when it is hardest to answer by feel — before promoting a local
skill into the shared agent rules or the team's skill set, where it starts steering everyone.

**You own the experiment design.** Frame, blind, run, synthesize.

## Non-negotiables for blinding

Get these wrong and the run measures nothing.

- **No meta vocabulary anywhere a candidate can see it.** Not `eval`, `test`, `judge`, `experiment`,
  `rubric`, `score`, `compare`, `benchmark`, `candidate`, `arena`, `variant`, `A/B` — not in a
  directory name, a file name, a branch name, or the prompt.
- **The prompt looks like an organic request.** State the goal the way the user would type it. Never
  the meta.
- **No chain-eliciting cues.** Do not ask a candidate which skills, principles or files it applied.
  Asking makes it perform the chain instead of following it. Grade chain-following from the
  transcript and the shape of the output.
- **Sanitize names.** Use project-shaped directory and branch names a person would plausibly pick.
- **Never tell a candidate other candidates exist.**
- **The judge may know it is judging**, but sees outputs by sanitized label only — never a model
  name, never which arm an output came from.
- **Two variants means one judge scoring both sets in a single pass on one scale.** Two judging
  passes are two scales.

## Steps

### 0. Read both arms before anything else

The literal first move: read the two versions you are comparing, end to end.

```bash
git diff HEAD -- <skill directory>                            # an uncommitted edit
git log -p --follow -- <skill directory>/SKILL.md | head -200  # a past edit
```

If there is only one version — a skill that exists versus no skill at all — say so explicitly and
treat "no skill" as the baseline arm. If you cannot name two arms, this is not an eval; stop and do
the edit instead.

### 1. Frame

State what is under test and what counts as success. Write a rubric of 3 to 6 concrete, gradeable
criteria. **The rubric is the judge's tool. Candidates never see it.**

Name the arms explicitly. The usual shapes: skill present vs absent, old wording vs new wording, or
a brief with the repo's non-obvious rules vs without.

### 2. Build sanitized environments

One working directory per candidate, each containing the arm's skill set and a plausible project
skeleton — enough context that the request reads as real work.

**Pin the working directory per candidate. This is the failure mode that silently ruins the run.**
Subagents inherit the session's working directory rather than the one described in their brief, so
prose like "work in /tmp/foo" is not isolation. Pin it mechanically:

- Claude candidates: launch with `isolation: "worktree"`, or give every command in the brief an
  explicit absolute path.
- Codex candidates: `codex exec -C /tmp/<sanitized-name>` — the `-C` flag, per
  `delegating-to-codex`, not a sentence in the prompt.

Two candidates sharing one directory are one candidate with extra steps, and they will clobber each
other's edits.

### 3. Author one organic prompt

What a person would actually type. The same prompt goes to every candidate. No leakage of what is
being measured.

### 4. Spawn candidates in parallel

Mixed panel: Claude via the `Agent` tool and Codex (small and large model) via
`delegating-to-codex`. Mixing families measures two things at once — whether the skill helps, and
whether it survives a model that did not write it. A skill that only works on the model it was
drafted with is not ready to be shared.

Run at least two candidates per arm so a single bad draw does not decide it. If a candidate produces
nothing, proceed with N-1 and record the dropout.

### 5. Spawn one blinded judge

A Claude subagent on a strong tier, seeing the rubric and the outputs by sanitized label. It scores
criterion by criterion and does not know which arm produced what. Give it the outputs in a shuffled
order and keep the label→arm mapping in your own notes only.

### 6. Verify the chain from transcripts, never from self-report

This is the step that separates a real eval from a vibe check.

- Claude candidates: the local session transcripts, at
  `~/.claude/projects/<project-slug>*/<session-uuid>/subagents/agent-<id>.jsonl`, with
  `agent-<id>.meta.json` beside it. A candidate launched into a worktree writes under
  `<project-slug>--claude-worktrees-<name>/`, so glob `<project-slug>*`.
- Codex candidates: the run's log file, per `delegating-to-codex`. Wait for the process to exit
  before reading it — a state file can report `running` after death, and reading early gives you a
  half-written tree.

Read which files each candidate actually opened and what it actually ran. Grade chain-following from
that plus the shape of the output. A candidate that never opened the skill file did not use the
skill, whatever its summary says.

### 7. Read every output yourself

End to end, before looking at the judge's verdict. Then compare. **Disagreement between you and the
judge is a finding**: either a model is biased or the rubric is ambiguous. Resolve it explicitly
rather than deferring to the judge.

## Reply

The arm under test, the rubric, per-candidate notes, the judge's verdict, your synthesis, and a
recommendation: promote, keep iterating, or drop. For a promotion recommendation, say which
destination — personal skill, shared project skill plus a PR, or the shared agent rules file — and
remember the shared ones need the user's go-ahead before the PR.

## Cost note

A full run is N candidates plus a judge on real tasks. Reach for it before promoting something
shared or before rewriting a skill people already depend on, not for a typo fix.

## Provenance

Ported from the `eval` playbook in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)
(Lauren Tan, MIT). The blinding non-negotiables and transcript-based chain verification are theirs;
the mixed Claude/Codex panel, the cwd-pinning failure mode and the transcript paths are ours.
