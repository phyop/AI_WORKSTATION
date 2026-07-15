# AI Workstation V1 Implementation Plan

This plan turns a Windows workstation into a controlled AI engineering environment. It is written for a public repository and intentionally avoids real host, account, network, path, and credential values.

## Objectives

- Build a repeatable workstation setup.
- Separate administrator maintenance from standard development work.
- Add OpenSSH only through staged validation.
- Keep all secrets and runtime state outside Git.
- Preserve an auditable trail of design decisions and validation results.

## Phase 0: Inventory

Collect only privacy-safe facts:

- operating system family and edition class;
- CPU, memory, storage, and GPU capability at a summary level;
- power configuration summary;
- time synchronization state;
- network posture without publishing IP addresses or adapter identifiers.

Deliverable: `docs/setup/phase-0-inventory.md`.

## Phase 1: Repository Foundation

Create the repository structure:

- `README.md` for the public overview;
- `ARCHITECTURE.md` for boundaries and components;
- `SECURITY.md` for publication and access rules;
- `ROADMAP.md` for phased rollout;
- `docs/decisions/` for ADRs;
- `bootstrap/windows/` for PowerShell scripts;
- `tests/` for repository checks.

Deliverable: a clean public GitHub repository.

## Phase 2: Local Safety Baseline

Tasks:

- configure time synchronization through a reviewed script;
- create a dedicated standard development account;
- avoid putting passwords in command history, logs, or chat;
- keep the administrator account for installation and recovery only.

Validation:

- standard account exists and is not an administrator;
- time service reports a healthy source;
- no credentials are tracked by Git.

## Phase 3: OpenSSH Rollout

Tasks:

- install OpenSSH Server;
- start and configure the service;
- verify local TCP and protocol behavior;
- keep inbound firewall exposure closed until key-based authentication is ready.

Important lesson: Windows servicing can appear stuck while DISM and CBS continue processing. Timeouts should trigger diagnostics before repeated installation attempts.

Validation:

- OpenSSH Server capability is installed;
- `sshd` service is running and set to automatic;
- local handshake works;
- unauthenticated batch login fails as expected;
- inbound exposure remains controlled.

## Phase 4: Key-Based Authentication

Tasks:

- generate SSH keys outside Git;
- store private keys in a secret manager or protected local storage;
- install public keys for the standard user;
- verify key login;
- disable or restrict password authentication.

Validation:

- key login works;
- password login is disabled or restricted;
- public key metadata contains no private key material.

## Phase 5: Private Remote Access

Tasks:

- add VPN or private overlay access;
- restrict SSH to trusted network sources;
- validate remote and mobile clients.

Validation:

- external access requires the private network boundary;
- direct public exposure is avoided.

## Phase 6: Development Toolchain

Tasks:

- install Git, Python, Codex, and editors;
- document repeatable setup commands;
- keep tool credentials outside the repository;
- add recovery notes for common failures.

## Human Approval Gates

Human approval is required for:

- administrator elevation;
- account creation or password changes;
- firewall or network exposure changes;
- GitHub visibility changes;
- publishing public documentation;
- destructive cleanup or rollback.

## Completion Criteria

The project is ready when:

- public documentation is English and privacy-safe;
- scripts are reviewable and scoped;
- secrets are ignored and validated;
- OpenSSH is gated behind key and network controls;
- Medium and GitHub publications point to the same public story.
