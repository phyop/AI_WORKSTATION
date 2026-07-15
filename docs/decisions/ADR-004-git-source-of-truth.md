# ADR-004: Use Git as the Source of Truth

## Decision

Git stores documentation, scripts, ADRs, examples, and validation records.

## Rationale

The workstation must be reproducible and auditable. Git history records what changed and why, while `.gitignore` and validation scripts prevent secrets and runtime artifacts from being tracked.
