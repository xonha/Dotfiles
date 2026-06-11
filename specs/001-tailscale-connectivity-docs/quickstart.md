# Quickstart Validation Guide: Tailscale Connectivity Documentation

**Phase**: 1 — Design
**Date**: 2026-06-11
**Purpose**: Verify that `docs/infra.md` satisfies all acceptance scenarios
after implementation. Run these scenarios on a machine in the fleet.

---

## Prerequisites

- Tailscale is running and authenticated on the machine you're testing from
  (`tailscale status` shows peers as online)
- `~/.ssh/config` aliases are deployed (`stow .` has been run from repo root)
- `console` is powered on (required for `devbox` scenarios)

---

## Scenario 1: SSH Alias Quick Reference (US1, P1)

**Goal**: Confirm a developer can open the doc and connect to any alias
without additional lookups.

**Steps**:

1. Open `docs/infra.md` in a browser or terminal (do not open any other page).
2. Locate the SSH alias table — it should be visible within the first screenful.
3. Run each command and verify the connection succeeds:

   ```bash
   ssh laptop       # Expected: shell on ThinkPad (Arch Linux)
   ssh maistodos    # Expected: shell on work machine (Arch WSL2)
   ssh devbox       # Expected: shell inside devbox container on console
   ```

4. After connecting via `ssh devbox`, verify port forward is active:

   ```bash
   # In a separate terminal on your connecting machine:
   curl -s http://localhost:3000 || echo "no service on 3000 (expected if nothing running)"
   ```

   The absence of a "connection refused" at the OS level (vs a service 404)
   confirms the forward is live.

**Pass criteria**: All three connections succeed; port 3000 is forwarded
(connectable, even if no app is listening). Time from opening the doc to
first connection: under 2 minutes.

---

## Scenario 2: Network Topology Read (US2, P2)

**Goal**: Confirm a reader with no prior knowledge can map the fleet correctly.

**Steps**:

1. Give the document to someone unfamiliar with the fleet (or simulate by
   covering your screen and reading fresh).
2. After one read-through, answer without consulting anything else:
   - What is `console`'s role?
   - What containers/services run on `console` and on which ports?
   - How does Tailscale MagicDNS affect hostname resolution?

**Pass criteria**: All three questions answered correctly without re-reading.
Expected answers:
- `console` = home server running Podman containers
- `devbox` on 2222, `n8n` on 5678
- MagicDNS resolves hostnames across machines; no IPs needed

---

## Scenario 3: devbox Connection Troubleshooting (US3, P3)

**Goal**: Confirm the troubleshooting section guides a developer to root cause.

**Steps** (simulate a broken devbox):

1. On `console`, stop the devbox container:
   ```bash
   systemctl --user stop devbox   # or equivalent service name
   ```
2. From any other machine, run `ssh devbox` — expect timeout or refused.
3. Open `docs/infra.md` troubleshooting section.
4. Follow the steps: verify the container is running.
5. On `console`, restart devbox:
   ```bash
   systemctl --user start devbox
   ```
6. Reconnect: `ssh devbox` — expect success.

**Pass criteria**: Developer identifies "container stopped" as root cause and
recovers without external searches. Time to diagnosis: under 3 minutes using
only the doc.

---

## Scenario 4: maistodos Tailscale Troubleshooting (US3, P3)

**Goal**: Confirm the doc explains the Windows host Tailscale quirk.

**Steps**:

1. Simulate `maistodos` being unreachable: on the Windows host, pause/stop
   Tailscale from the system tray.
2. From `laptop` or `console`, run `ssh maistodos` — expect timeout.
3. Open the troubleshooting section and follow the `maistodos` diagnostic path.
4. The doc must lead the reader to: "verify Tailscale is running on the
   Windows host, not just in WSL2".
5. Resume Tailscale on Windows; confirm `ssh maistodos` succeeds.

**Pass criteria**: Doc names the Windows Tailscale check explicitly; no
guessing required.

---

## Scenario 5: Public-Safety Spot Check (FR-009)

**Goal**: Confirm no sensitive data exists in the committed document.

**Steps**:

```bash
# From repo root — all should return zero matches:
grep -Ei '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' docs/infra.md
grep -Ei 'password|token|secret|api.?key|ssh-rsa|BEGIN.*PRIVATE' docs/infra.md
grep -Ei '@[a-z]+\.[a-z]+' docs/infra.md   # email addresses
```

**Pass criteria**: All three grep commands return no output (zero matches).

---

## Validation Checklist

- [ ] SC-001: SSH alias → live session in under 2 minutes (Scenario 1) — *requires live Tailscale*
- [ ] SC-002: Reader can describe all machine roles after single read (Scenario 2) — *manual review*
- [ ] SC-003: Troubleshooting identifies root cause without external searches (Scenarios 3 & 4) — *requires live Tailscale*
- [x] SC-004: No sensitive data in document (Scenario 5) — greps pass: no IPs, credentials, emails, or usernames
- [x] FR-008: SSH alias table visible within first screenful (Scenario 1, step 2) — table at lines 5–18
