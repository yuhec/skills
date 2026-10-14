# Codex adversarial pass (`adversarial` mode)

A second model family catches what the first one is blind to. Requires the `codex` CLI
(`command -v codex`); if absent, say "Codex indisponible" in the report and continue Claude-only.

## Run

Exclude generated artifacts from the diff Codex sees, and pin it read-only to the checkout (see
`delegating-to-codex` for the current large model id):

```bash
git diff origin/<base>...<head> -- . ':!**/*.lock' ':!**/package-lock.json' ':!<generated paths from review-rules>' > /tmp/review-diff.patch
codex exec -C "$(git rev-parse --show-toplevel)" -m <large-codex-model> -s read-only -o /tmp/codex-review.md \
  "You are an adversarial code reviewer. The diff to review is in /tmp/review-diff.patch; read surrounding code in this repository as needed. Find correctness bugs, regressions, security issues and design problems. For each: file:line, severity (critical/major/minor), the triggering scenario, a concrete fix. Ground every claim in the code; report nothing you cannot point to. Write your answer in French, keeping file paths, symbols and code in their original form." < /dev/null
```

Budget up to 5 minutes. On failure or timeout, continue Claude-only and say so.

## Merge

For each Codex finding, apply Step 5 (verify against the code) like any other finding, then tag it:

- **both** — Claude and Codex raised it: keep, high confidence;
- **Codex** — only Codex: keep if verified, drop otherwise (say why in one line under a
  "Rejetés" note only if the user asked for the full trace);
- **Claude** — only Claude: keep if still valid after re-reading;
- **disputed** — they contradict: re-read the code and decide, with the reason.
