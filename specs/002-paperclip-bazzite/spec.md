# Feature Specification: Paperclip on Bazzite

**Feature Branch**: `002-paperclip-bazzite`

**Created**: 2026-06-11

**Status**: Draft

**Input**: User description: "I want to implement a https://paperclip.ing/ on bazzite that should be accessible from within the tailscale network by all machines connected to it, paperclip is an AI agent orchestrator"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Access Paperclip UI from Any Tailscale Machine (Priority: P1)

A developer on any machine in the fleet (`laptop`, `maistodos`, or inside
`devbox`) opens a browser, navigates to the `console` host on the Paperclip
port, and reaches the Paperclip web UI without any additional setup.

**Why this priority**: The core value of the deployment — Paperclip is only
useful if it can be reached from wherever the developer is working.

**Independent Test**: From `laptop`, open a browser and navigate to
`http://console:<port>`. The Paperclip web UI loads and the sign-in or
onboarding screen is displayed. Repeat from `maistodos` and from within a
`devbox` SSH session using port forwarding or a browser on the host.

**Acceptance Scenarios**:

1. **Given** a developer is on any Tailscale-connected machine, **When** they
   navigate to `http://console:<port>` in a browser, **Then** the Paperclip
   UI loads within 5 seconds.
2. **Given** the Paperclip service is running on `console`, **When** a
   developer who has not previously visited the UI opens it, **Then** they are
   presented with an account creation or sign-in screen.
3. **Given** the developer completes sign-in, **When** they reach the
   Paperclip dashboard, **Then** they can create an agent team and assign
   tasks without errors.

---

### User Story 2 - Service Persists Across Reboots (Priority: P2)

A developer powers on `console` after it was shut down (planned or
unplanned). Paperclip is already running by the time the developer tries to
reach it — no manual intervention required.

**Why this priority**: A service that requires manual restarting after every
reboot is unreliable for day-to-day use. Automatic start is a baseline
expectation for self-hosted services on `console`.

**Independent Test**: Reboot `console`. Within 60 seconds of the machine
becoming reachable on Tailscale, navigate to `http://console:<port>` from
another machine and confirm the Paperclip UI loads. No manual command on
`console` should be required.

**Acceptance Scenarios**:

1. **Given** `console` is powered on from a cold state, **When** Tailscale
   reconnects, **Then** Paperclip is reachable at its URL without manual
   intervention.
2. **Given** Paperclip was running before a reboot, **When** the machine
   comes back up, **Then** all previously created agent teams, budgets, and
   ticket history are still present.
3. **Given** the service crashes for any reason, **When** the machine's
   service manager detects the crash, **Then** Paperclip restarts
   automatically.

---

### User Story 3 - Manage AI Agent Teams (Priority: P3)

A developer uses the Paperclip UI to create an agent team, assign a mission,
configure budgets, and delegate tasks — leveraging the AI model of their
choice (Claude, GPT, Gemini, etc.).

**Why this priority**: The deployment is only valuable if the core product
functionality works end-to-end. This validates that the service is not just
reachable but fully functional.

**Independent Test**: After signing in, create a new agent, assign it a
test task, and confirm the task is logged in the ticket history. Verify that
the agent budget display updates as expected.

**Acceptance Scenarios**:

1. **Given** a developer is signed in to Paperclip, **When** they create a
   new agent with a job description and monthly budget, **Then** the agent
   appears in the org chart and its budget is tracked.
2. **Given** an agent has been assigned a task, **When** the task completes,
   **Then** an immutable ticket log entry is created and the agent's cost
   utilization is updated.
3. **Given** a developer connects their AI provider API key, **When** they
   assign a task to an agent backed by that provider, **Then** the task
   executes using the correct model without errors.

---

### Edge Cases

- What happens when `console` loses its internet connection — can agents
  running locally still be managed through the UI?
- What if the database becomes corrupted — is there a backup or recovery path?
- What happens when an agent exhausts its monthly budget mid-task?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Paperclip MUST run as a persistent service on `console`
  (Bazzite host), managed by the machine's service manager so it starts on
  boot and restarts on failure.
- **FR-002**: The Paperclip web UI MUST be accessible from any
  Tailscale-connected machine (`laptop`, `maistodos`, `devbox`) using the
  `console` Tailscale hostname and a fixed port — no VPN configuration or
  port-forwarding rules required beyond what Tailscale already provides.
- **FR-003**: All Paperclip data (agent definitions, budgets, ticket history,
  user accounts) MUST persist on the host's filesystem across service
  restarts and machine reboots.
- **FR-004**: The deployment MUST follow the existing container and service
  management conventions used by `console` (rootless Podman + systemd user
  service), consistent with how `devbox` and `n8n` are managed.
- **FR-005**: The service configuration (environment variables, API keys for
  AI providers) MUST NOT be committed to the repository. Secrets are
  provisioned locally on `console` outside of version control.
- **FR-006**: The Paperclip port MUST NOT conflict with existing services on
  `console` (`devbox` on 2222, `n8n` on 5678).
- **FR-007**: The deployment MUST be documented in `docs/` and linked from
  the `CLAUDE.md` index, following the same pattern as `docs/devbox.md` and
  the n8n reference.
- **FR-008**: The service MUST be re-deployable from the dotfiles repo alone
  — a new `console` machine MUST be able to run Paperclip by following the
  documentation without undocumented manual steps. Because `console` is
  reachable via `ssh console` (Tailscale MagicDNS), the entire deployment
  process MUST be executable by an AI agent without any human intervention on
  the target machine.

### Key Entities

- **Paperclip Service**: The running Paperclip application on `console`.
  Attributes: port, persistence path, service unit name, restart policy.
- **Agent**: An AI persona with a role, job description, and monthly budget,
  managed through the Paperclip UI.
- **Agent Team / Org**: A collection of agents with defined reporting
  structure and shared mission.
- **Ticket**: An immutable log entry recording a task, its outcome, and the
  cost attributed to the executing agent.
- **AI Provider Credential**: A user-supplied API key for an external AI
  service (Claude, OpenAI, Gemini, etc.). Never stored in the repository.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The Paperclip UI loads in a browser on any Tailscale-connected
  machine within 5 seconds of navigation, measured from page request to
  interactive UI.
- **SC-002**: After a `console` reboot, Paperclip is reachable within 60
  seconds of Tailscale reconnecting — measured from network availability to
  UI response.
- **SC-003**: All agent data, budgets, and ticket history created before a
  reboot or restart are intact and accessible after the service comes back up
  (zero data loss on clean restart).
- **SC-004**: A developer with no prior Paperclip experience can follow the
  `docs/paperclip.md` documentation alone (no external references) to deploy
  the service on a fresh `console` machine.
- **SC-005**: The deployment passes a public-safety review: no credentials,
  API keys, or personal data present in any committed file.

## Assumptions

- `console` (Bazzite) is the designated host for all persistent services in
  the fleet; Paperclip follows this pattern.
- Rootless Podman with systemd user services is the preferred container
  runtime on `console`, consistent with `devbox` and n8n.
- The Paperclip default port (3100) does not conflict with existing services;
  if it does, the deployment documentation specifies the alternate port used.
- AI provider API keys (Claude, OpenAI, etc.) are supplied by the user
  post-deployment via the Paperclip UI or environment configuration — they
  are out of scope for the deployment itself.
- Tailscale MagicDNS is sufficient for network access; no reverse proxy,
  TLS termination, or domain name is required for within-fleet access.
- The deployment scope is the Tailscale-private fleet only; no public
  internet exposure is required or desired.
- Data backup and disaster recovery are out of scope for this feature; the
  persistence requirement covers normal restart/reboot cycles only.
- `console` is reachable from the development machine via `ssh console`
  (Tailscale MagicDNS alias). This means the full deployment — cloning
  dotfiles, stowing, building the container image, onboarding, allowlisting
  the hostname, and fixing container configuration — can be completed
  entirely by an AI agent over SSH without any human on the target machine.
  This is the intended replication path for future deployments.

## Clarifications

### Session 2026-06-11

- Q: Should FR-008's "re-deployable from dotfiles repo" explicitly include agent-driven deployment as a first-class scenario? → A: Yes — update FR-008 and add an assumption that `ssh console` access makes the entire process agent-executable (Option A).
