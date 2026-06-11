---

description: "Task list for Paperclip on Bazzite deployment"
---

# Tasks: Paperclip on Bazzite

**Input**: Design documents from `specs/002-paperclip-bazzite/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Not requested — validation is manual per quickstart.md scenarios.

**Organization**: Tasks are grouped by user story. Each story produces a
independently deployable and testable increment of the Paperclip service.

**Execution context**: Tasks T004 onward run on `console` (Bazzite host).
File-editing tasks (T003, T017–T019) run from the dotfiles repo on any machine.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (independent files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Dotfiles repo: `~/Dotfiles/` (or wherever the repo is cloned on `console`)
- Quadlet unit files: `.config/containers/systemd/` (tracked in dotfiles, deployed via `stow .`)
- Secrets file (local only): `~/.config/containers/systemd/paperclip.env`
- Data volume (local only): `~/.local/share/paperclip/`
- Documentation: `docs/paperclip.md`

---

## Phase 1: Setup

**Purpose**: Prepare the dotfiles repo with the necessary directory structure
and confirm `.gitignore` protects the secrets file before any content is written.

- [x] T001 Create `.config/containers/systemd/` directory in the dotfiles repo
  (if it does not already exist). This is the stow-managed path for Podman
  Quadlet unit files on `console`.

- [x] T002 Verify that `.gitignore` in the repo root contains the line
  `.config/containers/systemd/paperclip.env`. This was added during planning;
  confirm it is present before writing any unit files.

---

## Phase 2: Foundational

**Purpose**: Write the Quadlet unit files into the dotfiles repo and build
the Paperclip container image on `console`. These are blocking prerequisites
for all user stories.

**⚠️ CRITICAL**: User story phases require these files to be in place first.

- [x] T003 Write the three Quadlet unit files to `.config/containers/systemd/`
  in the dotfiles repo, copying from the upstream `paperclipai/paperclip`
  repository (`docker/quadlet/` directory). The files to create are:

  **`.config/containers/systemd/paperclip.pod`**:
  ```ini
  [Pod]
  PodName=paperclip
  PublishPort=3100:3100
  ```

  **`.config/containers/systemd/paperclip-db.container`**:
  ```ini
  [Unit]
  Description=PostgreSQL for Paperclip

  [Container]
  Image=docker.io/library/postgres:17-alpine
  ContainerName=paperclip-db
  Pod=paperclip.pod
  Volume=paperclip-pgdata:/var/lib/postgresql/data
  EnvironmentFile=%h/.config/containers/systemd/paperclip.env
  HealthCmd=pg_isready -U $POSTGRES_USER -d $POSTGRES_DB -h localhost || exit 1
  HealthInterval=15s
  HealthTimeout=5s
  HealthRetries=5

  [Service]
  Restart=on-failure
  TimeoutStartSec=60

  [Install]
  WantedBy=default.target
  ```

  **`.config/containers/systemd/paperclip.container`**:
  ```ini
  [Unit]
  Description=Paperclip AI Agent Orchestrator
  Requires=paperclip-db.service
  After=paperclip-db.service

  [Container]
  Image=paperclip-local
  ContainerName=paperclip
  Pod=paperclip.pod
  Volume=%h/.local/share/paperclip:/paperclip:Z
  Environment=HOST=0.0.0.0
  Environment=PAPERCLIP_HOME=/paperclip
  Environment=PAPERCLIP_DEPLOYMENT_MODE=authenticated
  Environment=PAPERCLIP_DEPLOYMENT_EXPOSURE=private
  Environment=PAPERCLIP_PUBLIC_URL=http://localhost:3100
  EnvironmentFile=%h/.config/containers/systemd/paperclip.env

  [Service]
  Restart=on-failure
  TimeoutStartSec=120

  [Install]
  WantedBy=default.target
  ```

  Note: `PAPERCLIP_PUBLIC_URL` will be overridden to `http://console:3100`
  by the local `.env` file in T007 (EnvironmentFile takes precedence as it
  appears after the Environment= lines in the unit).

- [ ] T004 On `console`: clone the upstream Paperclip repository and build the
  container image:
  ```bash
  git clone https://github.com/paperclipai/paperclip.git ~/paperclip-src
  cd ~/paperclip-src
  podman build -t paperclip-local .
  ```
  Confirm the image is available: `podman images | grep paperclip-local`.
  This image is built locally and NOT stored in git.

- [ ] T005 On `console`: create the Paperclip application data directory:
  ```bash
  mkdir -p ~/.local/share/paperclip
  ```
  This is the bind mount target for `Volume=%h/.local/share/paperclip:/paperclip:Z`
  in the Quadlet unit. It is local-only and gitignored implicitly by its location
  outside the repo.

**Checkpoint**: Quadlet files in dotfiles repo; image built on `console`; data
directory created. All user stories can now proceed.

---

## Phase 3: User Story 1 - UI Accessible from Tailscale (Priority: P1) 🎯 MVP

**Goal**: Any Tailscale-connected machine can navigate to `http://console:3100`
and reach the Paperclip sign-in screen.

**Independent Test**: From `laptop`, run `curl -s -o /dev/null -w "%{http_code}"
http://console:3100/` — expect 200 or 302. Open in browser; UI loads within
5 seconds. See `quickstart.md` Scenario 1.

### Implementation for User Story 1

- [ ] T006 [US1] On `console`: deploy the Quadlet unit files by running
  `stow .` from the dotfiles repo root. Verify the symlinks are created:
  ```bash
  ls -la ~/.config/containers/systemd/paperclip*
  ```
  Expected: three symlinks pointing into the dotfiles repo.

- [ ] T007 [US1] On `console`: create the secrets file at
  `~/.config/containers/systemd/paperclip.env` with the following content
  (substituting real values — this file is NEVER committed to git):
  ```env
  POSTGRES_USER=paperclip
  POSTGRES_PASSWORD=<generate with: openssl rand -base64 32>
  POSTGRES_DB=paperclip
  DATABASE_URL=postgres://paperclip:<POSTGRES_PASSWORD>@localhost:5432/paperclip
  BETTER_AUTH_SECRET=<generate with: openssl rand -base64 48>
  PORT=3100
  SERVE_UI=true
  PAPERCLIP_PUBLIC_URL=http://console:3100
  PAPERCLIP_DEPLOYMENT_MODE=authenticated
  PAPERCLIP_DEPLOYMENT_EXPOSURE=private
  ```
  Set restrictive permissions: `chmod 600 ~/.config/containers/systemd/paperclip.env`.

- [ ] T008 [US1] On `console`: reload systemd user daemon and start the
  Paperclip pod:
  ```bash
  systemctl --user daemon-reload
  systemctl --user start paperclip-pod
  ```
  Wait for services to become healthy (up to 60 seconds for DB startup):
  ```bash
  systemctl --user status paperclip-pod paperclip paperclip-db
  ```

- [ ] T009 [US1] Run quickstart Scenario 1 from `laptop` — verify the UI is
  reachable at `http://console:3100` from a remote Tailscale machine and
  loads within 5 seconds. Also verify from `maistodos` if available.

**Checkpoint**: Paperclip UI reachable from all Tailscale machines. US1
independently testable and validated.

---

## Phase 4: User Story 2 - Persists Across Reboots (Priority: P2)

**Goal**: `console` reboots bring Paperclip back automatically; all data is
intact after restart.

**Independent Test**: See `quickstart.md` Scenario 2 — reboot `console`,
navigate to `http://console:3100` within 60 seconds of Tailscale reconnecting,
confirm previously created data is present.

### Implementation for User Story 2

- [ ] T010 [US2] On `console`: enable the Paperclip services to start on boot:
  ```bash
  systemctl --user enable paperclip-pod paperclip paperclip-db
  ```

- [ ] T011 [US2] On `console`: enable linger so user services start without
  login (skip if already enabled for the devbox deployment):
  ```bash
  loginctl enable-linger $USER
  ```
  Verify: `loginctl show-user $USER | grep Linger` → should show `Linger=yes`.

- [ ] T012 [US2] Run quickstart Scenario 2 — reboot `console` and verify:
  (a) Paperclip is reachable within 60 seconds of Tailscale reconnect;
  (b) all agent data created in US1 testing is intact. Run quickstart Scenario 3
  (crash recovery) immediately after: kill the paperclip process and confirm
  systemd restarts it.

**Checkpoint**: Service survives reboots and crashes. US2 independently testable.

---

## Phase 5: User Story 3 - Manage AI Agent Teams (Priority: P3)

**Goal**: A developer can create an agent team, assign tasks, and verify the
ticket audit log — end-to-end functional validation.

**Independent Test**: See `quickstart.md` Scenario 4 — sign in, create an agent
with a budget, assign a task, confirm ticket log entry appears.

### Implementation for User Story 3

- [ ] T013 [US3] In the Paperclip UI at `http://console:3100`: complete the
  initial onboarding — create the first company/org and user account.

- [ ] T014 [US3] In the Paperclip UI: connect at least one AI provider API key
  (Claude, OpenAI, or another supported provider) via the Integrations or
  Settings section. The API key is entered in the UI and stored in the
  Paperclip database — it is NOT stored in any dotfile.

- [ ] T015 [US3] Run quickstart Scenario 4 end-to-end: create a test agent with
  a role (e.g., "Research Assistant"), monthly budget ($5), and a simple test
  task. Verify the ticket log entry appears and the budget display updates.
  Confirm the agent appears in the org chart.

**Checkpoint**: Full Paperclip workflow operates correctly. US3 independently
testable.

---

## Phase 6: Polish & Documentation

**Purpose**: Documentation, infra reference update, and final validation.

- [x] T016 [P] Write `docs/paperclip.md` documenting the full deployment for
  `console`. The doc MUST cover (with exact commands):
  - Prerequisites (Bazzite, rootless Podman with Quadlet, Tailscale active)
  - Build the `paperclip-local` image from upstream (T004 steps)
  - Create data directory (T005)
  - Deploy Quadlet files via `stow .` (T006)
  - Create `paperclip.env` with required variables and generate commands for
    secrets (T007 — show `openssl rand` commands but NOT real values)
  - Start and enable services (T008, T010, T011)
  - Enable linger (T011)
  - Verify UI at `http://console:3100`
  - Service management commands (`systemctl --user start/stop/restart/status paperclip-pod`)
  - Rebuild after upstream update (re-clone or `git pull` + `podman build`)
  - Troubleshooting: check logs (`journalctl --user -u paperclip`), DB health,
    image not found errors

- [x] T017 [P] Add `docs/paperclip.md` to the `CLAUDE.md` index under the
  Infrastructure section:
  ```markdown
  - [Paperclip](docs/paperclip.md) — AI agent orchestrator on console (Podman + Quadlet)
  ```

- [x] T018 Update `docs/infra.md` Services on console table to add Paperclip:
  | `paperclip` | — | 3100 | AI agent orchestrator (see [paperclip.md](paperclip.md)) |
  Depends on T016 existing so the link is valid.

- [x] T019 Run quickstart Scenario 5 (public-safety check) against all newly
  committed files:
  ```bash
  grep -r 'password\|secret\|token\|api.?key' .config/containers/systemd/*.container .config/containers/systemd/*.pod
  git check-ignore -v .config/containers/systemd/paperclip.env
  grep -Ei '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' .config/containers/systemd/*.container
  ```
  All must return zero matches / file is ignored. Fix any leaks found.

- [ ] T020 Run quickstart Scenario 6 (re-deployability) by stepping through
  `docs/paperclip.md` as if on a fresh machine. Mark each quickstart.md
  validation checklist item complete.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately (can run on any machine)
- **Foundational (Phase 2)**: Depends on Phase 1 completion
  - T003 (write unit files) can run on any machine after T001-T002
  - T004-T005 (build image, create dir) run on `console` after T003
- **User Stories (Phases 3–5)**: All depend on Phase 2 completion
  - US1 must complete before US2 and US3 (services must be running)
  - US2 depends on US1 (needs running services to test persistence)
  - US3 depends on US1 (needs accessible UI)
- **Polish (Phase 6)**: Depends on all user story phases completing

### Within Phase 2

- T003 (write Quadlet files to repo) has no dependencies — can run immediately
- T004 (build image on console) and T005 (create data dir) are independent
  of each other [P] but both depend on T003 being committed/stowed

### Within Polish Phase

- T016 (write paperclip.md) and T017 (update CLAUDE.md index) are [P] —
  different files, no dependency
- T018 (update infra.md) depends on T016 existing (to make the link valid)
- T019 (safety check) can run as soon as T003 is done — no dependency on docs
- T020 (re-deployability) depends on T016 being complete

### Parallel Opportunities

```bash
# Phase 2 — after T003 is committed, these can run in parallel on console:
Task: "T004 Build paperclip-local image on console"
Task: "T005 Create ~/.local/share/paperclip/ directory"

# Polish Phase — these are independent:
Task: "T016 [P] Write docs/paperclip.md"
Task: "T017 [P] Add to CLAUDE.md index"
Task: "T019 [P] Run public-safety check"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Build image + Quadlet files (T003–T005)
3. Complete Phase 3: Deploy and start service (T006–T009)
4. **STOP and VALIDATE**: Scenario 1 — UI reachable from `laptop`
5. Ship if basic access is sufficient for immediate needs

### Incremental Delivery

1. Setup + Foundational → image built, files in repo
2. US1 → UI accessible → validate → usable (MVP)
3. US2 → persistence enabled → reboot-test → reliable
4. US3 → agent workflow validated → fully functional
5. Polish → documented + infra.md updated → production-ready

---

## Notes

- [P] tasks = independent files or checks, no cross-task conflicts
- T004 (image build) requires internet access on `console` to pull from GitHub
  and Docker Hub; run before enabling firewall restrictions
- `BETTER_AUTH_SECRET` MUST be generated fresh with `openssl rand -base64 48`
  — never use the upstream dev default `paperclip-dev-secret`
- Linger (T011) may already be enabled if `devbox.service` is running; check
  before re-running `loginctl enable-linger`
- The `paperclip-src/` clone from T004 can be deleted after the image is built;
  it is not needed for ongoing operation (only for rebuilds after upstream updates)
- All AI provider API keys are entered through the Paperclip UI — they are
  stored in the PostgreSQL database, not in dotfiles or environment variables
