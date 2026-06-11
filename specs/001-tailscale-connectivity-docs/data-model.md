# Data Model: Tailscale Connectivity Documentation

**Phase**: 1 — Design
**Date**: 2026-06-11

This document defines the conceptual entities that the documentation must
accurately describe. These are not database schemas — they are the real-world
objects the reader needs to understand to navigate the fleet.

---

## Entity: Machine

Represents a physical or virtual host enrolled in the Tailscale network.

| Attribute | Type | Description |
|-----------|------|-------------|
| `alias` | string | SSH alias used in `~/.ssh/config` (e.g., `laptop`) |
| `tailscale_hostname` | string | MagicDNS name Tailscale resolves (e.g., `laptop`) |
| `hardware` | string | Physical description (e.g., ThinkPad, Desktop PC) |
| `os` | string | Operating system (e.g., Arch Linux, Bazzite, Windows + Arch WSL) |
| `role` | string | Primary function in the fleet |
| `hosted_services` | Service[] | Services running persistently on this machine |
| `quirks` | string[] | Non-obvious networking behaviours requiring doc callouts |

### Instances

| alias | tailscale_hostname | hardware | os | role | quirks |
|-------|--------------------|----------|----|------|--------|
| `laptop` | `laptop` | ThinkPad | Arch Linux | Primary client — Hyprland desktop | None |
| `console` | `console` | Desktop PC | Bazzite (Fedora Silverblue) | Home server — runs containers | Host for `devbox` container and n8n |
| `maistodos` | `maistodos` | Work PC | Windows + Arch WSL2 | Work machine | Tailscale runs on Windows host, not in WSL2 |

---

## Entity: SSH Alias

Represents a named shortcut in `~/.ssh/config` that maps to a host and
carries optional connection configuration.

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Alias name used in `ssh <name>` |
| `hostname` | string | Resolved Tailscale hostname or IP |
| `port` | int | SSH port (default 22; overridden for containers) |
| `user` | string | Login user (omitted from public doc — referenced generically) |
| `local_forwards` | PortForward[] | LocalForward rules applied on connect |
| `target_machine` | Machine | The machine this alias reaches |

### Instances

| name | hostname | port | local_forwards | target_machine |
|------|----------|------|----------------|----------------|
| `laptop` | `laptop` | 22 | none | laptop |
| `maistodos` | `maistodos` | 22 | none | maistodos |
| `devbox` | `console` | 2222 | 3000→localhost:3000 | console (container) |
| *(direct)* | `console` | 22 | none | console |

> Note: `console` has no named alias yet. Access via `ssh <user>@console` or
> by adding an alias manually. The doc should note this and provide the
> direct command.

---

## Entity: Container / Service

Represents a persistent workload running on a machine.

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Service or container name |
| `parent_machine` | Machine | Host machine running this service |
| `ssh_port` | int\|null | SSH port exposed (containers only) |
| `service_port` | int\|null | Application port exposed |
| `purpose` | string | What the service does |
| `manager` | string | How it is managed (e.g., Podman + systemd user service) |

### Instances

| name | parent_machine | ssh_port | service_port | purpose | manager |
|------|----------------|----------|--------------|---------|---------|
| `devbox` | console | 2222 | — | Arch Linux dev environment | Podman + systemd user service |
| `n8n` | console | — | 5678 | Workflow automation | Podman + systemd user service (Quadlet) |

---

## Entity: Port Forward

Represents a `LocalForward` rule applied by an SSH alias on connect.

| Attribute | Type | Description |
|-----------|------|-------------|
| `local_port` | int | Port bound on the connecting machine |
| `remote_host` | string | Host resolved from inside the SSH target |
| `remote_port` | int | Port on `remote_host` |

### Instances

| local_port | remote_host | remote_port | via alias | purpose |
|------------|-------------|-------------|-----------|---------|
| 3000 | localhost | 3000 | `devbox` | Web services running in the devbox container |

---

## Relationships

```text
Machine ──hosts──> Container/Service (1..N)
SSH Alias ──reaches──> Machine (N..1, via Tailscale hostname + port)
SSH Alias ──applies──> PortForward (0..N)
```
