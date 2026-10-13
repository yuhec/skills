---
name: pr-comments
description: Use to triage the review comments of a pull request into a verdict table — for each comment, whether it is pertinent, why, and how to resolve it — before touching any code. Triggers include "pr-comments 3762", "tu penses quoi des commentaires de la PR X", "note les commentaires de la PR dans un tableau", "est-ce que ces commentaires sont pertinents", or a pasted block of review comments. Not for writing a review yourself (use reviewing-code) and not for applying the fixes.
---

# Triage of PR review comments

Input: a PR number, or a block of comments pasted by the user (then skip the fetch).
Output: one table in chat, in the user's language. **Change no code, post no reply, resolve no
thread** — this skill only judges.

## Step 1 — Fetch every comment

```bash
gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate \
  -q '.[] | "\(.id) | \(.user.login) | \(.path):\(.line // .original_line) | reply_to=\(.in_reply_to_id // "")\n\(.body)\n---"'
gh api repos/{owner}/{repo}/pulls/<n>/reviews -q '.[] | select(.body != "") | "\(.user.login) | \(.state) | \(.body)"'
gh api repos/{owner}/{repo}/issues/<n>/comments -q '.[] | select(.user.login | test("bot|sonar") | not) | "\(.user.login): \(.body)"'
```

- Group a reply thread (`reply_to`) with its root comment: one row per thread.
- Skip bot summaries (task links, quality-gate reports). Keep a bot's inline finding.
- Skip a thread already answered in it and marked resolved.

## Step 2 — Judge each comment against the real code

For each comment, read the commented lines **at the PR head**, not the local checkout:

```bash
gh pr view <n> --json headRefName -q .headRefName
git fetch origin && git show "origin/<head>:<path>" | sed -n '<line-20>,<line+20>p'
```

Then check, before deciding:

- **the claim itself** — does the code actually do what the comment says? A comment can be right
  about the smell and wrong about the consequence (a fallback that already exists, a value that can
  never be `undefined`). Say which part holds.
- **the repo rules** (`CLAUDE.md` / `.claude/CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`) and the
  existing pattern in neighbouring code — a rule or a precedent settles most comments on its own;
  cite it.
- **decisions already taken** with the user or in the ticket: if the comment contradicts one, the
  verdict is ⚠️, never a silent pick.

Verdict vocabulary: **✅ Oui** · **Partiellement** · **Non** · **⚠️ À trancher** (it depends on a
business rule or a prior decision only the user can settle).

## Step 3 — The table

| # | Où | Commentaire | Pertinent ? | Pourquoi | Résolution |
|---|---|---|---|---|---|
| 1 | `path/file.py:112` | the comment, condensed to one line | ✅ Oui | the fact from the code or the rule that decides it | the concrete change, with real symbol names |

- **Où** is a clickable `path:line`; **Commentaire** is condensed, never pasted whole.
- **Pourquoi** states evidence (a file, a rule, a behaviour), not an opinion.
- **Résolution** is actionable: the function to change, the existing helper or exception to reuse,
  the test to add. For **Non**, say what to answer the reviewer.
- Order rows by the file order of the diff.

## Step 4 — After the table

- List the **⚠️ decisions** the user must take, each as one question with a recommendation.
- Point out when two resolutions are coupled (same function, or one follows from another) and
  propose the order to apply them in.
- End with one line: offer to apply the pertinent ones, and to draft replies to the reviewer
  (never posted without the user's go).
