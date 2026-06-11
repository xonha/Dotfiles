# Feature Specification: Tailscale Connectivity Documentation

**Feature Branch**: `001-tailscale-connectivity-docs`

**Created**: 2026-06-11

**Status**: Draft

**Input**: User description: "We need a solid documentation on how the 3 machines connect to each other, we can use the aliases (maistodos, laptop, console, devbox) to connect to them and they use tailscale"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Connect to Any Machine via SSH Alias (Priority: P1)

A developer sits down at any machine in the fleet and needs to open a shell on
another. They recall there are aliases but want a single reference that tells
them which alias to use, what it resolves to, and any gotchas.

**Why this priority**: Day-to-day workflow — the most frequent need across all
machines. Without this a developer falls back to guessing or trial-and-error.

**Independent Test**: Open `docs/infra.md` cold (without prior knowledge) and
successfully SSH into all four alias targets (`laptop`, `maistodos`, `console`,
`devbox`) using only the information in the document. Each connection MUST be
reachable within two minutes of reading.

**Acceptance Scenarios**:

1. **Given** a developer has Tailscale running on their machine, **When** they
   read the SSH alias table, **Then** they can copy the correct `ssh <alias>`
   command for each host and connect without any additional lookup.
2. **Given** a developer wants to reach `devbox`, **When** they follow the
   alias section, **Then** they understand that `devbox` is a container on
   `console` (port 2222) and that local port 3000 is forwarded automatically.
3. **Given** a developer wants to reach `maistodos`, **When** they read its
   section, **Then** they understand that Tailscale runs on the Windows host and
   the WSL2 environment is reachable through it.

---

### User Story 2 - Understand the Network Topology (Priority: P2)

A new contributor (or the repo owner returning after months away) needs to
understand what machines exist, what roles they serve, and how they talk to
each other — without access to a live terminal.

**Why this priority**: Mental model clarity prevents mis-routing work (e.g.,
running a server workload on the laptop) and reduces onboarding friction.

**Independent Test**: A reader with no prior knowledge can draw a correct
network diagram of all machines, their roles, and their connection paths after
reading the document. Verification: the diagram they draw matches the actual
topology.

**Acceptance Scenarios**:

1. **Given** a reader unfamiliar with the fleet, **When** they read the machine
   table, **Then** they can name each host's hardware, OS, and primary role.
2. **Given** a reader wants to know which services run on which machine, **When**
   they read the infrastructure doc, **Then** they find a complete list of
   running containers/services on `console` and their ports.
3. **Given** a reader wants to know how Tailscale connects the fleet, **When**
   they read the Tailscale section, **Then** they understand that MagicDNS
   resolves hostnames across all machines and no IP addresses are needed for
   routine work.

---

### User Story 3 - Troubleshoot a Failed Connection (Priority: P3)

A developer finds that `ssh devbox` or `ssh maistodos` is not working and
needs diagnostic steps to determine whether the issue is Tailscale, SSH
configuration, or the container itself.

**Why this priority**: Connectivity failures are infrequent but high-friction
when they occur. Clear troubleshooting steps reduce downtime.

**Independent Test**: Simulate a broken connection scenario (e.g., Tailscale
not running), then verify a developer can identify the root cause using only
the troubleshooting section of the doc, without external searches.

**Acceptance Scenarios**:

1. **Given** `tailscale status` shows a peer as offline, **When** the developer
   reads the troubleshooting section, **Then** they know the recovery steps for
   a disconnected peer.
2. **Given** `ssh devbox` times out, **When** the developer consults the doc,
   **Then** they know to verify that the `devbox` container on `console` is
   running and that port 2222 is open.
3. **Given** `maistodos` is unreachable, **When** the developer reads its
   section, **Then** they know to verify Tailscale is running on the Windows
   host (not just in WSL2).

---

### Edge Cases

- What happens when Tailscale is not running on the connecting machine?
- What if `console` is powered off — what aliases become unavailable?
- How does a developer reach `console` itself (not just `devbox`) via SSH?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Documentation MUST cover all four SSH aliases (`laptop`,
  `maistodos`, `console`, `devbox`) with their resolved hostname and any
  non-obvious connection details (port overrides, port forwarding).
- **FR-002**: Documentation MUST include a machine roster table listing each
  host's hardware, OS, and role.
- **FR-003**: Documentation MUST explain that Tailscale MagicDNS resolves
  hostnames across all machines and that IP addresses are not required for
  routine work.
- **FR-004**: Documentation MUST describe the `devbox` alias accurately:
  it targets `console:2222` (a Podman container) and forwards local port 3000.
- **FR-005**: Documentation MUST describe the `maistodos` networking quirk:
  Tailscale runs on the Windows host; WSL2 is reachable through the Windows
  Tailscale address.
- **FR-006**: Documentation MUST list services running on `console` with their
  ports (`devbox` on 2222, n8n on 5678).
- **FR-007**: Documentation MUST include a troubleshooting section with
  diagnostic commands and recovery steps for common failure modes (peer
  offline, container stopped, Tailscale not running).
- **FR-008**: Documentation MUST be structured so the SSH alias reference
  (FR-001) is reachable within the first screenful or clearly linked from a
  top-level summary.
- **FR-009**: Documentation MUST NOT contain any credentials, IP addresses,
  tokens, or personal data — it is published in a public repository.

### Key Entities

- **Machine**: A physical or virtual host in the fleet. Attributes: alias,
  hardware, OS, Tailscale hostname, role, hosted services.
- **SSH Alias**: A named shortcut in `~/.ssh/config` that maps to a host,
  port, user, and optional port-forward rules.
- **Container/Service**: A workload running on a machine. Attributes: name,
  exposed port, purpose, parent host.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer can go from reading the document to a live SSH
  session on any alias target in under 2 minutes, measured from opening the
  doc to shell prompt.
- **SC-002**: A reader unfamiliar with the fleet can correctly describe all
  machine roles and connectivity paths after a single read-through.
- **SC-003**: A developer experiencing a connectivity failure can identify the
  likely root cause from the troubleshooting section without leaving the
  document (zero external searches required for common failure modes).
- **SC-004**: The document passes a public-safety review: no sensitive data,
  no personal identifiers, no internal credentials present anywhere in the file.

## Assumptions

- The SSH config aliases (`laptop`, `maistodos`, `console`, `devbox`) are
  already deployed via `stow .` on all machines; the doc explains their
  meaning, not how to install them.
- Tailscale is pre-installed and authenticated on all machines; the doc covers
  usage and troubleshooting, not initial Tailscale setup.
- The existing `docs/infra.md` is the target file to expand/replace — no new
  doc file is introduced unless the existing one cannot accommodate the changes.
- `console` is the only machine running persistent services; `laptop` and
  `maistodos` are client-only for the purposes of this doc.
- Port 3000 local forwarding via the `devbox` alias is intentional (for web
  services in the container) and should be documented, not removed.
