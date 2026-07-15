# ADR-003: Treat Agents as Scoped Operators

## Decision

AI agents should operate in scoped project workspaces and should not receive administrator privileges by default.

## Rationale

Agent tooling can accelerate setup, documentation, validation, and troubleshooting. It should not bypass human approval for accounts, credentials, firewall rules, or publication side effects.
