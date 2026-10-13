# Lens — quality

Apply the project's own coding rules first (agent rules file, `.claude/review-rules.md`); they win
over anything below.

## SOLID and object design
- **SRP**: one reason to change per class/module/function.
- **OCP**: extend without editing existing contracts.
- **LSP**: subtypes usable wherever the base is.
- **ISP**: no dependency on methods the consumer does not use; ports narrow to their consumer.
- **DIP**: depend on abstractions; injected dependencies named after the role, not the concrete class.
- **Tell, don't ask** and **Demeter**: no deep chains through unrelated objects.

## Clean code
- Names say what a thing is; no temporary/placeholder names; no misleading name patched by a comment.
- Short functions, one level of abstraction, shallow nesting (extract named helpers).
- No magic values; no duplicated literals that belong in one constant or config.
- Loops driven by a clear condition, not `while True` + `break` when avoidable.
- Cleanup: no debug prints/logs, `breakpoint()`, commented-out code, dead code, stray TODOs.

## Web API (if the diff touches one)
- Routes in their router, not in the app entrypoint; request/response schemas separate from the
  domain model; validation by the framework, not by hand.
- Dependency injection through the framework; no global mutable state.
- Errors with semantic status codes; no `try/except` that swallows.

## Frontend (if the diff touches one)
- Components display; reusable logic in composables/hooks; API calls centralised in services/stores.
- Stores scoped; no state duplicated between local and store; typed props/emits; no deep prop drilling.
- Correct reactivity (no prop mutation, computed over watcher when possible); stable list keys;
  test ids where the project uses them.

Severity: mostly 🟡/🟢. A quality issue becomes 🔴 only when it causes a bug or breaks a project rule
that is enforced elsewhere (CI, lint).
