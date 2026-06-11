# Quickstart Validation Guide: Paperclip on Bazzite

**Phase**: 1 — Design
**Date**: 2026-06-11
**Purpose**: Verify the Paperclip deployment satisfies all acceptance scenarios.
Run these after completing implementation on `console`.

---

## Prerequisites

- `console` is running Bazzite with rootless Podman and Quadlet support
- Tailscale is active and `console` is reachable from the connecting machine
- Dotfiles have been deployed on `console` via `stow .` from the repo root
- The `paperclip-local` container image has been built on `console`
- `~/.config/containers/systemd/paperclip.env` exists and contains all
  required variables (see `data-model.md` — Environment File entity)
- `~/.local/share/paperclip/` directory exists on `console`
- Systemd user services are enabled: `paperclip-db`, `paperclip`, `paperclip-pod`

---

## Scenario 1: UI Accessible from Remote Machine (SC-001, FR-002)

**Goal**: Confirm any Tailscale machine can reach the Paperclip UI.

**From `laptop` or `maistodos`:**

```bash
curl -s -o /dev/null -w "%{http_code}" http://console:3100/
# Expected: 200 or 302 (redirect to sign-in page)
```

Then open `http://console:3100` in a browser. The Paperclip sign-in or
onboarding screen MUST load within 5 seconds.

**Pass criteria**:
- HTTP response code 200 or 302 from `curl`
- UI renders in browser within 5 seconds
- No "connection refused" or timeout errors

---

## Scenario 2: Service Survives Reboot (SC-002, SC-003, FR-001, FR-003)

**Goal**: Confirm Paperclip starts automatically after `console` reboots and
data persists.

**Steps**:

1. Create a test agent in the Paperclip UI (give it a name and budget).
2. On `console`, reboot:
   ```bash
   sudo systemctl reboot
   ```
3. Wait for `console` to come back online on Tailscale:
   ```bash
   tailscale status   # run from laptop or maistodos — wait for console to appear online
   ```
4. Navigate to `http://console:3100` from another machine.
5. Confirm: the test agent created in step 1 is still present.

**Pass criteria**:
- Paperclip is reachable within 60 seconds of `console` appearing on Tailscale
- The test agent and its budget are present (no data loss)
- No manual command was required on `console`

---

## Scenario 3: Service Health Check (FR-001 — Restart on Failure)

**Goal**: Confirm systemd restarts Paperclip automatically on crash.

**On `console`:**

```bash
# Check current service status
systemctl --user status paperclip

# Simulate a crash
systemctl --user kill --signal SIGKILL paperclip

# Wait 5 seconds, then check status
sleep 5 && systemctl --user status paperclip
```

**Pass criteria**: `systemctl status` shows the service as `active (running)`
after the kill — not `failed` or `inactive`.

---

## Scenario 4: End-to-End Agent Management (FR-002, US3)

**Goal**: Confirm the full Paperclip workflow operates correctly.

**Steps**:

1. Sign in to Paperclip at `http://console:3100`.
2. Create a new company / org.
3. Hire an agent: give it a role (e.g., "Research Assistant"), a job
   description, and a monthly budget (e.g., $5).
4. Assign a simple task to the agent.
5. Verify the ticket log shows the task entry.
6. Verify the agent's cost utilization is displayed on the dashboard.

**Pass criteria**: All steps complete without errors; ticket log entry is
visible and immutable; budget display updates.

---

## Scenario 5: Public-Safety Check (FR-005, SC-005)

**Goal**: Confirm no secrets are in tracked files.

**Run from repo root (any machine with the repo cloned):**

```bash
# Check Quadlet unit files for secrets
grep -r 'password\|secret\|token\|api.?key' .config/containers/systemd/*.container .config/containers/systemd/*.pod
# Expected: zero matches (EnvironmentFile= references only, no values)

# Confirm .env file is gitignored
git check-ignore -v .config/containers/systemd/paperclip.env
# Expected: output confirming the file is ignored

# Confirm no IP addresses in tracked files
grep -Ei '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' .config/containers/systemd/*.container
# Expected: zero matches
```

**Pass criteria**: All three grep commands return zero matches; `git check-ignore`
confirms the `.env` file is ignored.

---

## Scenario 6: Re-deployability from Dotfiles (FR-008, SC-004)

**Goal**: Confirm a fresh `console` can be set up using only `docs/paperclip.md`.

**Test (can be done on a VM or documented as a checklist):**

1. Open `docs/paperclip.md` — do NOT consult any other resource.
2. Follow the steps from top to bottom on a fresh Bazzite machine.
3. After completion, navigate to `http://console:3100` and confirm the UI loads.

**Pass criteria**: All steps in the doc complete without additional research;
UI is functional at the end. Time to working deployment: under 30 minutes.

---

## Validation Checklist

- [ ] SC-001: UI loads within 5 seconds from any Tailscale machine (Scenario 1)
- [ ] SC-002: Service reachable within 60 seconds of `console` boot (Scenario 2)
- [ ] SC-003: All data intact after reboot (Scenario 2)
- [ ] SC-004: Fresh deployment possible from `docs/paperclip.md` alone (Scenario 6)
- [ ] SC-005: No secrets in tracked files (Scenario 5)
- [ ] FR-001: Service restarts automatically on crash (Scenario 3)
- [ ] FR-002: UI accessible from all Tailscale machines (Scenario 1)
- [ ] FR-004: Quadlet + systemd user service pattern followed (Scenario 3)
