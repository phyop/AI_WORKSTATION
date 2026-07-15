# Roadmap

## Phase 0: Inventory

- Record privacy-safe operating system, hardware, power, and time-service facts.
- Avoid real hostnames, account names, IP addresses, serial numbers, and raw logs.

## Phase 1: Repository Baseline

- Keep documentation, scripts, ADRs, and validation notes in Git.
- Keep credentials and runtime state out of Git.
- Verify ignore rules with tests.

## Phase 2: Local Safety Baseline

- Configure time synchronization.
- Create a dedicated standard user for development work.
- Keep administrator access separate for installation and recovery.

## Phase 3: OpenSSH Rollout

- Install OpenSSH Server.
- Validate local service state and protocol handshake.
- Keep inbound firewall exposure closed until public-key authentication and network boundaries are ready.

## Phase 4: Key-Based Access

- Generate and store SSH private keys outside Git.
- Install public keys for the standard user.
- Restrict password authentication after key login succeeds.

## Phase 5: Private Remote Access

- Add VPN or private overlay access.
- Limit SSH exposure to trusted network sources.
- Validate mobile and remote workflows.

## Phase 6: Development Toolchain

- Install Git, Python, Codex, editors, and project-specific tools.
- Document repeatable setup and recovery steps.
