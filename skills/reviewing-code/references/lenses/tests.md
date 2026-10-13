# Lens — tests

## Coverage of the change
- Every behaviour change has a test added or updated; a bug fix has a regression test that fails
  without the fix.
- New branches (`if`, `match` arm, early return, new exception) are each exercised.
- No existing test was edited only to make the change pass, without the reason for the break being
  understood and addressed (compare the test diff with the source diff).
- Tests assert public behaviour, not private methods or attributes.

## Test shape (generic)
- One behaviour per test; no branching or loops inside a test; near-identical tests differing only
  by inputs are parametrized.
- An "expect exception" block wraps exactly one call that can raise — no setup or assertions inside.
- Readable: full variable names, named values instead of magic ones, setup that says what matters.
- Mocks only at real boundaries, built the way the project builds them; no mock wrapped where a
  return value suffices.
- No duplicated tests; no test ids generated at import time (random ids in parametrize).

## Project conventions
Apply the test conventions table of `.claude/review-rules.md` (naming pattern, file/class
organisation, arrange/act/assert layout, factories, mocking primitive, markers) to every changed or
added test file. If the project has a `writing-tests` skill, it is the reference.

For each finding: the test file and line, the rule, the fix (the new name, the split, the
parametrize).
