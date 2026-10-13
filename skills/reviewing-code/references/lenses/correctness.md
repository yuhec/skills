# Lens — correctness

Find behaviour that is wrong, not code that is ugly. Every finding names the input or state that
triggers it.

- **Logic**: inverted conditions, off-by-one, wrong operator, wrong variable, early return that skips
  work, a `match`/`switch` missing a variant, default branches that hide a new case.
- **Edge inputs**: absent / `None` / empty string / empty list / zero / one / many, boundaries of a
  limit, duplicates, unicode, timezones, very large inputs.
- **Error handling**: swallowed exceptions, broad `except`/`catch` that turns a bug into a silent
  skip, errors mapped to the wrong status (a client error surfacing as a 500, a 500 hidden as a 200),
  partial writes left behind on failure.
- **Async & concurrency**: a coroutine not awaited, blocking I/O inside async code, read-then-write
  races, a uniqueness checked in code but not enforced by the storage (no index/constraint), shared
  mutable state, non-idempotent retries.
- **Data compatibility**: data written by the old code read by the new one (renamed field, new
  required field, changed enum value); a migration missing or not matching the model change; soft
  deleted rows counted or returned.
- **Contracts**: a changed request/response shape, query parameter or status code with clients
  that were not updated; a removed field still read somewhere (`grep` the consumers, generated
  clients included).
- **Resources**: unclosed files/connections, unbounded loops or queries (missing pagination/limit),
  N+1 queries introduced in a loop.
- **Config**: a new setting with no default and no entry in the env example; a feature flag read
  with the wrong name.

For each finding: the triggering scenario in one line, the consequence, the fix.
