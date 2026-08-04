---
name: define
description: Define jargon, abbreviations, and unique strings used in this conversation
disable-model-invocation: true
argument-hint: "[terms...]"
---

Define jargon used in this conversation so the user can follow along.

**Arguments:** `$ARGUMENTS`

- If arguments were given, define exactly those terms (comma- or space-separated).
- If no arguments, scan your recent messages and pick out the terms a reader would have to look up: acronyms, spec names, protocol/format identifiers, tool names, and domain jargon (e.g. `at+jwt`, `JWKS`, `IdP`). Skip terms whose meaning was already explained inline in the conversation, and skip common programming vocabulary the user clearly knows.

## Output format

One bullet per term, most fundamental terms first (so later definitions can build on earlier ones):

- **TERM** (expansion, if it's an acronym) — one- or two-sentence definition. Anchor it to how the term was actually used in this conversation, not a generic dictionary entry.

Example:

- **JWT** (JSON Web Token) — a signed, self-contained token: header + claims + signature, base64-encoded. Anyone with the public key can verify it without calling the issuer.
- **JWKS** (JSON Web Key Set) — a JSON document of public keys published by the identity server at a well-known URL; verifiers fetch it to check JWT signatures locally.
- **at+jwt** — the `typ` header value marking a JWT as an OAuth access token (RFC 9068), so an `id_token` can't be replayed as an access token.
- **IdP** (Identity Provider) — the server that authenticates users and mints tokens (here, IdentityServer).

No preamble, no closing summary — just the definitions.
