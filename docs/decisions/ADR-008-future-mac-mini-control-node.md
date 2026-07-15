# ADR-008: Leave Room for a Future Control Node

## Decision

The design should allow a future always-on control node, such as a small desktop or mini server, without changing the current workstation safety model.

## Rationale

A control node can later host scheduling, monitoring, or agent orchestration. It must inherit the same least-privilege, secret-management, and audit principles.
