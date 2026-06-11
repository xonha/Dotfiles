# Data Model: Paperclip on Bazzite

**Phase**: 1 — Design
**Date**: 2026-06-11

This document describes the deployment entities — the runtime objects and files
that the implementation must create and manage. Paperclip's internal data model
(agents, tickets, org charts) is owned by the upstream application and lives in
the PostgreSQL database; it is not reproduced here.

---

## Entity: Quadlet Unit File

A systemd-native Podman container definition tracked in the dotfiles repo.

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Unit filename (e.g., `paperclip.pod`) |
| `type` | enum | `pod`, `container` |
| `path` | string | `$HOME`-relative path in repo and on disk |
| `deployed_via` | string | `stow .` from repo root |

### Instances

| name | type | path |
|------|------|------|
| `paperclip.pod` | pod | `.config/containers/systemd/paperclip.pod` |
| `paperclip.container` | container | `.config/containers/systemd/paperclip.container` |
| `paperclip-db.container` | container | `.config/containers/systemd/paperclip-db.container` |

---

## Entity: Container

A running Podman container within the `paperclip` pod.

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Container name |
| `image` | string | Container image |
| `role` | enum | `server`, `database` |
| `managed_by` | string | Quadlet unit file name |
| `restart_policy` | string | Systemd restart behavior |

### Instances

| name | image | role | managed_by |
|------|-------|------|------------|
| `paperclip` | `paperclip-local` (built locally) | server | `paperclip.container` |
| `paperclip-db` | `postgres:17-alpine` | database | `paperclip-db.container` |

---

## Entity: Podman Pod

Groups the two containers and publishes the external port.

| Attribute | Value |
|-----------|-------|
| `name` | `paperclip` |
| `published_port` | `3100:3100` |
| `managed_by` | `paperclip.pod` |

---

## Entity: Volume

Persistent storage attached to containers.

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Volume name or bind mount path |
| `type` | enum | `named`, `bind` |
| `mount_path` | string | Path inside the container |
| `host_path` | string | Named volume or host bind path |
| `backed_up` | bool | Whether data recovery exists (out of scope) |

### Instances

| name | type | host_path | mount_path | container |
|------|------|-----------|------------|-----------|
| `paperclip-pgdata` | named | *(Podman manages)* | `/var/lib/postgresql/data` | `paperclip-db` |
| `paperclip-data` | bind | `~/.local/share/paperclip` | `/paperclip` | `paperclip` |

---

## Entity: Environment File

The secrets configuration file that lives only on `console`, never in git.

| Attribute | Value |
|-----------|-------|
| `path` | `~/.config/containers/systemd/paperclip.env` |
| `tracked_in_git` | No — gitignored |
| `loaded_by` | Both `paperclip.container` and `paperclip-db.container` via `EnvironmentFile=` |

### Required variables

| Variable | Example value | Sensitive |
|----------|---------------|-----------|
| `POSTGRES_USER` | `paperclip` | No |
| `POSTGRES_PASSWORD` | `<strong-random>` | **Yes** |
| `POSTGRES_DB` | `paperclip` | No |
| `DATABASE_URL` | `postgres://paperclip:<pw>@localhost:5432/paperclip` | **Yes** |
| `BETTER_AUTH_SECRET` | `<64-char-random>` | **Yes** |
| `PORT` | `3100` | No |
| `SERVE_UI` | `true` | No |
| `PAPERCLIP_PUBLIC_URL` | `http://console:3100` | No |
| `PAPERCLIP_DEPLOYMENT_MODE` | `authenticated` | No |
| `PAPERCLIP_DEPLOYMENT_EXPOSURE` | `private` | No |

---

## Entity: Container Image

The locally-built Paperclip server image.

| Attribute | Value |
|-----------|-------|
| `name` | `paperclip-local` |
| `source` | Cloned `paperclipai/paperclip` repo on `console` |
| `build_command` | `podman build -t paperclip-local .` (from repo root) |
| `rebuild_trigger` | Upstream version update; Dockerfile change |

---

## Entity: Documentation File

| File | Path | Purpose |
|------|------|---------|
| `paperclip.md` | `docs/paperclip.md` | Deployment, operations, and troubleshooting reference |

Linked from `CLAUDE.md` index under the Infrastructure section.

---

## Relationships

```text
Quadlet Pod (paperclip.pod)
  └── publishes port 3100

Quadlet Container (paperclip.container)
  ├── image: paperclip-local (built from GitHub source)
  ├── env: EnvironmentFile → paperclip.env
  ├── volume: ~/.local/share/paperclip → /paperclip
  └── depends-on: paperclip-db.container

Quadlet Container (paperclip-db.container)
  ├── image: postgres:17-alpine
  ├── env: EnvironmentFile → paperclip.env
  └── volume: paperclip-pgdata → /var/lib/postgresql/data

paperclip.env (local only, gitignored)
  └── loaded by both container units
```
