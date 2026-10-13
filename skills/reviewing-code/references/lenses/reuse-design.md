# Lens — reuse and design (diff vs the wider codebase)

Do not reason about the diff alone. For each meaningful unit the diff introduces or changes
(function, class, helper, constant, type, branch of logic), **search the codebase** — by name, by
signature, by behaviour keyword, in the relevant domain folder — and ask:

1. **Duplicate logic** — does it reimplement an existing helper, parser, mapper or query? Cite it.
2. **Ignored abstraction** — a hardcoded value that already has an enum/constant; a string where an
   enum exists; a per-type `if/elif` that an existing registry, strategy or data-driven seam already
   handles; a conversion the repo already owns at its boundaries (id parsing, date parsing).
3. **Generalization** — two near-identical blocks (in the diff, or one in the diff and one existing)
   that should be one parametrized function; a concrete class that should implement an existing
   interface.
4. **Layering** — business logic in a route/controller/component; infrastructure instantiated
   inside business logic instead of injected; one model serving as domain entity, storage document
   and HTTP contract at once (the tell: serialization aliases or framework config on a domain type).
5. **Types** — a closed set of possibilities carried by a runtime table/registry/validator instead of
   types (a discriminated union per family makes invalid combinations unrepresentable); a catch-all
   variant (`OTHER`, `UNSUPPORTED`, `default → nothing`) on a closed set; an identifier typed as a
   bare `str` when a named id type exists; a cast or ignore added only to satisfy the typechecker.
6. **New vocabulary** — a new name for a concept the codebase already names (`quantity` for
   `measure`). Grep the new word and its neighbours; zero hits elsewhere means it needs a reason.
7. **YAGNI** — code for hypothetical needs: options nobody passes, extension points with one
   implementation, an endpoint nothing calls, a field exposed that no consumer reads.
8. **Pattern fit** — only when it genuinely simplifies: sprawling type branching → strategy/registry;
   many-branch construction → factory/builder; duplicated setup/teardown → context manager/template
   method; flag-driven behaviour → polymorphism. If the straightforward code is already clear, say so.

Every finding cites **both** the diff location **and** the existing code it should converge on.
A suggestion without that second citation is an opinion — drop it or say why no precedent exists.
