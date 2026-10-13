# Lens — security

Only what the diff introduces or touches. Each finding names the attacker-controlled input and the
path it takes.

- **Injection**: user input reaching a query (SQL/NoSQL operators, raw filters), a shell command, a
  template, a regex, a file path (traversal), an outbound URL (SSRF), HTML (XSS) without the
  framework's escaping.
- **Authorization**: a new route or action without the auth dependency the neighbouring routes have;
  an object fetched by id without checking it belongs to the caller's tenant/organisation/user;
  role checks done on the client only.
- **Validation at the boundary**: unvalidated sizes, types, enums; uploads without type/size limits;
  pagination without a maximum.
- **Secrets**: keys, tokens, passwords, connection strings in code, tests, fixtures, logs or examples;
  `.env` files added to git.
- **Sensitive data exposure**: personal or secret data in logs, error messages, query parameters,
  responses that return more fields than the client needs.
- **Dependencies**: a new package — is it maintained, pinned, and needed? A lockfile change without a
  manifest change.
- **Crypto & randomness**: home-made crypto, `random` for tokens, weak hashes for passwords.

For a deeper pass on a security-sensitive change, suggest the built-in `/security-review` in the
report rather than duplicating it.
