# AI Engineering Platform Roadmap

This document records the broader platform direction behind the AI Workstation project. The public version focuses on reusable architecture and omits private operational identifiers.

## V1: Single Workstation

Goal: build one secure workstation that can support local development, remote access, and AI-assisted engineering.

Key capabilities:

- Git source of truth for documentation and repeatable scripts
- standard development account separate from administrator maintenance
- OpenSSH installed behind explicit security gates
- secrets stored outside Git
- privacy-safe public documentation

## V2: Remote Access Layer

Goal: add private remote access without exposing the workstation directly.

Key capabilities:

- VPN or private overlay network
- restricted SSH source ranges
- mobile SSH client validation
- public-key authentication
- password-authentication hardening

## V3: Agent Pool

Goal: support multiple agent workflows without giving every tool broad system power.

Key capabilities:

- least-privilege task accounts where needed
- project-specific workspaces
- auditable logs with sensitive values redacted
- human approval for destructive or externally visible actions

## V4: Cross-Platform Control Plane

Goal: extend the pattern to macOS and Linux while preserving the same safety model.

Key capabilities:

- platform-specific bootstrap scripts
- shared ADRs and policy documents
- reusable secret-management patterns
- validation checks for public documentation

## Design Principles

- Start with boundaries before adding capabilities.
- Keep recovery access separate from agent access.
- Treat public documentation as a product surface.
- Make every high-risk action explicit, reviewable, and reversible when possible.
