---
name: maintaining-verification-skills
description: Use to audit an existing verifying-* skill and its feature map against what the service actually does now — "est-ce que le skill de vérif est encore à jour ?", after a batch of changes to a service, or when a verification run failed for a reason that smells like drift rather than a bug. Covers every feature from source and exercises every feature live, then ships at most one PR of proven corrections.
---

# Maintaining a verification skill

A feature map rots the moment the service changes. This is the upkeep loop for a skill produced by
`creating-verification-skills`.

**Which skill do you want?** Need proof that the service works *right now*, for a change you are
shipping → the `verifying-*` skill itself. Need to know whether the *skill* still matches the
service → here. A failed verification run starts as the former: debug it there, and come here only
once the failure looks like the map describing behaviour the service no longer has.

**The unit of rigour is the feature, not the sentence.** Cover every feature file from source and
exercise every feature live, without terminalising every bullet.

## Outcomes

Pick one and say which:

- **clean** — every feature got source and live coverage, nothing worth shipping. No branch, no PR.
- **changed** — one PR of proven doc, harness or map corrections.
- **blocked** — coverage could not finish, or a proven fix could not ship safely. Say exactly what
  blocked it.

## Edit scope

**Only the verification skill's own directory**: its `SKILL.md`, its `features/`, its scripts.

Never edit product code during a run. Behaviour the map describes that the service no longer does is
either doc drift (fix the map) or a regression (report it, do not paper over it).

## Pass

### 0. Locate the target
Find the `verifying-*` skill with launch/drive sections and a feature map. Several candidates → ask
which. None → stop and point at `creating-verification-skills`.

### 1. Index hygiene
Read the audited skill's own `features/README.md`, glob its siblings, fix missing, extra, duplicate
or dead entries. Light touch, no generated inventory.

### 2. Source wave
One read-only subagent per feature file, launched concurrently. Each answers "how does this
user-facing feature work?" from source, flags likely drift with `file:line` citations, and returns
one concise live-verification recipe. **Children never drive the service and never edit files.**

Return shape: feature summary / source entry points / likely drift or none / one recipe.

### 3. Reconcile
Every feature file has a returned summary. Merge overlapping recipes into as few service states as
practical. Spot-check cited drift; do not re-prove clean claims.

Sweep recent churn (`git log --since=<last audit> --stat`) for user-facing surfaces missing from the
map — require a concrete source path before calling one missing.

### 4. Live pass
**Required even when source looks clean.** The coordinator owns all driving. Follow the
verification skill's own Launch section for the instance model: one long-lived instance driven
serially for an API, a fresh run per drive for a job/DAG.

Hold three invariants the whole pass, whatever fails:

1. **Never drive an instance you have not health-checked since it last surprised you.** Doctor
   before the first drive, doctor again after any failed drive. Where doctor cannot see the failure
   — a wedged state on a healthy process — reset or relaunch rather than hoping.
2. **Evidence captured so far survives every cleanup**, checked at its named location, not assumed.
3. **Nothing a drive started outlives that drive's usefulness.** Failed-iteration residue is cleaned
   whether the run is stuck, exited, or shared. For a shared instance, clean the residue, not the
   instance.

A doctor failure caused by skill drift **is drift**: fix it under edit scope, restart only what the
fix invalidated, retry once, and only then call the pass `blocked`.

A feature that cannot be reached is `verified-unreachable` only with the concrete unmet
prerequisite and the route attempted. If the map omits that prerequisite, that is drift.

Any harness fix gets re-driven live before it ships. Final teardown happens after the last drive,
re-proofs included.

### 5. Triage
| What you found | What it is | What to do |
|---|---|---|
| Wrong or missing user-POV description | doc drift | fix the map |
| Working behaviour the harness cannot drive | harness gap | fix the harness, re-drive it |
| Behaviour that is actually broken | product gap | record it for the user, keep it out of this PR |

### 6. Ship or stop
**changed** → one PR of proven corrections, re-reading every changed file first. Verification
skills are shared team assets, so a change to one goes through a PR like any other shared code.

**clean** or **blocked** → no PR. Report the outcome and the coverage honestly.

Keep run notes (features covered, unreachable prerequisites, confirmed drift, outcome) in a
gitignored working folder, and do not commit them.

## Provenance

Ported from `maintain-verification-skill` in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)
(Lauren Tan, MIT). The three live-pass invariants and the outcome vocabulary are theirs.
