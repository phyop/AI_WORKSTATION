# Portfolio Collateral

## STAR Resume Bullets

- Designed a privacy-safe public documentation set for a Windows AI workstation, translating sensitive local setup work into reusable architecture, ADRs, threat modeling, and validation scripts without exposing host, account, path, or network identifiers.
- Built a phased OpenSSH rollout plan with DISM/CBS diagnostics, service validation, firewall gating, and human approval checkpoints, reducing the risk of prematurely exposing remote access.
- Implemented a least-privilege workstation model that separates administrator maintenance from standard AI-agent development work and keeps credentials outside Git.
- Created repository validation and publication hygiene rules that check for secrets, runtime files, local paths, and public-documentation language consistency.

## LinkedIn Summary

I built a public, privacy-safe blueprint for turning a Windows laptop into a secure AI engineering workstation. The project combines Git-based documentation, PowerShell bootstrap scripts, OpenSSH rollout gates, least-privilege account design, threat modeling, ADRs, and human approval checkpoints. The core lesson: remote AI capability should be added only after identity, secrets, network boundaries, and recovery paths are explicit.

## Conventional Commit

```text
docs: convert AI workstation public content to English
```

## PR Description

### Summary

Converts the public AI Workstation repository documentation to English and aligns it with the public GitHub and Medium publication rules.

### Changes

- Rewrote README, architecture, roadmap, security, ADRs, setup notes, troubleshooting notes, and Medium article source in English.
- Preserved privacy-safe placeholders for host, account, path, network, and log identifiers.
- Added publication-ready Medium article content.

### Testing

- Run repository validation script.
- Run `git diff --check`.
- Re-scan tracked Markdown for CJK content and sensitive local identifiers.

### Screenshots

Not applicable.

### Future Work

- Add VPN overlay implementation notes.
- Add SSH public-key rollout validation.
- Add CI for documentation privacy checks.

## Follow-On Projects

- AI Software Engineer: package the validation checks into reusable CI.
- AI Solution Architect: extend the workstation blueprint to a multi-node private agent environment.
- AI Agent Consultant: build an audit template for public-safe agent-assisted infrastructure projects.
