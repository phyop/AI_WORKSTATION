# ADR-007: Prefer VPN-First Remote Access

## Decision

SSH should be reachable only through a VPN, private overlay, or trusted network boundary before any broader exposure is considered.

## Rationale

Remote access is useful only when its blast radius is controlled. VPN-first access reduces public attack surface while still supporting mobile and remote workflows.
