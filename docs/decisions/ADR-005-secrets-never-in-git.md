# ADR-005: Never Store Secrets in Git

## Decision

Private keys, tokens, OAuth files, cookies, `.env` files, and runtime reports must stay outside Git.

## Rationale

Private repositories are confidential storage, not secret storage. Public repositories require an even stricter standard. Commit only examples and placeholders.
