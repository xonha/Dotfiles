# Implementation Plan: Tailscale Connectivity Documentation

**Branch**: `001-tailscale-connectivity-docs` | **Date**: 2026-06-11 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-tailscale-connectivity-docs/spec.md`

## Summary

Expand and harden `docs/infra.md` so it serves as a complete, self-contained
reference for how the three-machine Tailscale fleet (`laptop`, `console`,
`maistodos`) connects — covering the SSH alias table, per-machine quirks
(devbox container routing, maistodos WSL2/Windows Tailscale split), services
running on `console`, and a troubleshooting decision tree. No new files are
introduced; the target is the existing `docs/infra.md`.

## Technical Context

**Language/Version**: Markdown — no runtime version

**Primary Dependencies**: N/A — documentation only; no libraries or build tooling

**Storage**: Files — `docs/infra.md` (existing, to be expanded in-place)

**Testing**: Manual validation — read the document cold, run the SSH commands,
verify each alias resolves and connects; spot-check no sensitive data present

**Target Platform**: All machines in the fleet + any reader of the public
GitHub repository

**Project Type**: Documentation

**Performance Goals**: Readability — a developer can go from opening the doc
to a live SSH session in under 2 minutes (SC-001)

**Constraints**: No credentials, IP addresses, tokens, or personal data in the
file (FR-009, constitution "No secrets in git"); must fit in the single
existing `docs/infra.md` file per the spec assumption

**Scale/Scope**: One Markdown file; 3 physical/virtual machines; 4 SSH aliases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| I. Stow-First | ✅ PASS | `docs/infra.md` lives at a `$HOME`-relative path in the repo; symlinked via `stow .` — no hand-copy needed |
| II. Reproducible | ✅ PASS | No new system dependencies; pure Markdown edit |
| III. Idempotent | ✅ PASS | Updating a doc is idempotent by nature |
| IV. Server Base, Desktop Additive | ✅ PASS | No packages being installed |
| V. Machine-Specific Stays Untracked | ✅ PASS | Doc uses Tailscale MagicDNS names (intentionally portable), not raw IPs; no machine-specific generated files |
| No secrets (PUBLIC REPO) | ✅ PASS | FR-009 explicitly forbids IPs, credentials, tokens, personal data; using only alias names that are safe to publish |

**Gate result: PASS — proceed to Phase 0**

## Project Structure

### Documentation (this feature)

```text
specs/001-tailscale-connectivity-docs/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source (repository root)

```text
docs/
└── infra.md   # Target file — expand in-place

.ssh/
└── config     # SSH alias source-of-truth (read-only reference; not modified by this feature)
```

**Structure Decision**: Pure documentation feature — no `src/` or `tests/`
directories. The only deliverable is an improved `docs/infra.md`. The
`.ssh/config` file is already the authoritative alias definition and is
referenced (not changed) by the doc.

## Complexity Tracking

> No constitution violations — section left blank per template guidance.
