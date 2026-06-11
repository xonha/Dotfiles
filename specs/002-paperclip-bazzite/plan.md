# Implementation Plan: Paperclip on Bazzite

**Branch**: `002-paperclip-bazzite` | **Date**: 2026-06-11 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-paperclip-bazzite/spec.md`

## Summary

Deploy Paperclip (AI agent orchestrator) on `console` (Bazzite host) using the
upstream project's official Podman Quadlet unit files. The service runs as two
rootless Podman containers (Paperclip server + PostgreSQL sidecar) managed by
systemd user services, following the same pattern as `devbox`. The web UI is
exposed on port 3100 and reachable from any Tailscale-connected machine via
`http://console:3100`. Quadlet files are tracked in the dotfiles repo and
deployed via `stow .`; secrets stay in a local, gitignored `.env` file.

## Technical Context

**Language/Version**: Node.js 20+ (inside Paperclip container image); Podman 4+
with Quadlet support (Bazzite ships this)

**Primary Dependencies**:
- Paperclip server image — built locally on `console` from the upstream
  GitHub source (`paperclipai/paperclip`)
- PostgreSQL 17 Alpine — pulled from `docker.io/library/postgres:17-alpine`
- Podman Quadlet — Bazzite's systemd-native container management

**Storage**:
- Named Podman volume `paperclip-pgdata` → PostgreSQL data
- Bind mount `~/.local/share/paperclip` → Paperclip application data
  (tickets, agent state, uploads)

**Testing**: Manual validation per `quickstart.md` scenarios; no automated
tests (infrastructure deployment)

**Target Platform**: Bazzite (Fedora Silverblue) on `console`; rootless Podman
user session

**Project Type**: Service deployment / infrastructure (not an Arch `.install.sh`
feature — `console` is Bazzite; a standalone doc covers its setup)

**Performance Goals**: UI interactive within 5 seconds of navigation (SC-001);
service reachable within 60 seconds of `console` boot (SC-002)

**Constraints**:
- Port 3100 — no conflict with existing services (devbox:2222, n8n:5678)
- `BETTER_AUTH_SECRET` MUST be a strong random value set in the local `.env`
  file — the default `paperclip-dev-secret` MUST NOT be used in deployment
- `PAPERCLIP_PUBLIC_URL` set to `http://console:3100` for correct link
  generation when accessed from other Tailscale machines
- No credentials committed to git (constitution + FR-005)

**Scale/Scope**: Single-machine personal fleet deployment; no internet exposure

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| I. Stow-First | ✅ PASS | Quadlet files live at `.config/containers/systemd/` — the correct `$HOME`-relative path; deployed via `stow .` |
| II. Reproducible | ✅ PASS | `docs/paperclip.md` documents every step; no undocumented manual steps. Note: `console` is Bazzite (not Arch), so `.install.sh` does not apply — the doc is the bootstrap |
| III. Idempotent | ✅ PASS | Quadlet + `systemctl --user enable --now` is idempotent; `podman build` is re-runnable |
| IV. Server Base, Desktop Additive | ✅ PASS | Paperclip is a headless server service; no GUI dependency; `console` is the headless host |
| V. Machine-Specific Stays Untracked | ✅ PASS | `~/.config/containers/systemd/paperclip.env` (secrets) is gitignored; `~/.local/share/paperclip/` (data volume) is gitignored |
| No secrets (PUBLIC REPO) | ✅ PASS | `.env` file gitignored; `BETTER_AUTH_SECRET` never committed; only hostname/port in tracked files |

**Gate result: PASS — proceed to Phase 0**

## Project Structure

### Documentation (this feature)

```text
specs/002-paperclip-bazzite/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source (repository root)

```text
.config/containers/systemd/
├── paperclip.pod           # Podman pod definition — publishes port 3100
├── paperclip.container     # Paperclip server Quadlet unit
└── paperclip-db.container  # PostgreSQL sidecar Quadlet unit

docs/
└── paperclip.md            # Deployment & operations reference
```

**Gitignored (local-only on `console`):**

```text
~/.config/containers/systemd/paperclip.env   # secrets: DB password, auth secret, public URL
~/.local/share/paperclip/                    # application data volume
```

**Structure Decision**: Quadlet unit files tracked in dotfiles at their correct
`$HOME`-relative paths. The `.env` secret file is excluded. A build step on
`console` produces the `paperclip-local` container image from upstream source.

## Complexity Tracking

> No constitution violations — section left blank per template guidance.
