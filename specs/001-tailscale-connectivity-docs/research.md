# Research: Tailscale Connectivity Documentation

**Phase**: 0 — Outline & Research
**Date**: 2026-06-11
**Status**: Complete — all decisions resolved, no external research required

## Summary

All information needed for this documentation feature is already present in the
repository (`docs/infra.md`, `.ssh/config`, `docs/devbox.md`,
`docs/n8n-bazzite.md`). No NEEDS CLARIFICATION markers remained in the spec.
This document records the structural and editorial decisions made during the
planning phase.

---

## Decision 1: Target File — Expand in-place vs New File

- **Decision**: Expand the existing `docs/infra.md` in-place
- **Rationale**: The spec assumption states no new file unless the existing one
  cannot accommodate the changes. `infra.md` is already linked from `CLAUDE.md`
  and serves the exact same audience. Creating a parallel file would split the
  reference and require updating the index.
- **Alternatives considered**: New `docs/network.md` — rejected because it
  duplicates the surface area and breaks the existing index link.

---

## Decision 2: Document Structure Order

- **Decision**: Order sections as: Quick Reference (SSH aliases) → Machine
  Roster → Tailscale → Per-Machine Details → Services on console →
  Troubleshooting
- **Rationale**: US1 (connect quickly) is P1; readers wanting the SSH command
  must find it in the first screenful (FR-008). Topology context (US2) follows.
  Troubleshooting (US3) is last because it's consulted reactively.
- **Alternatives considered**: Topology-first order — rejected because US1 is
  P1 and the daily workflow is "give me the alias", not "explain the network".

---

## Decision 3: SSH Alias Coverage — Include `console` Direct Access

- **Decision**: Document `console` as a direct SSH target even though no alias
  exists in `.ssh/config` today, and note how to add one.
- **Rationale**: The spec edge case asks "how does a developer reach `console`
  itself?" The current `.ssh/config` has no `console` alias — the reader would
  reach it via Tailscale MagicDNS directly (`ssh henrique@console`). This
  should be documented explicitly to avoid confusion.
- **Alternatives considered**: Omit `console` direct access — rejected because
  it leaves an edge case (what if `devbox` container is down) undocumented.

---

## Decision 4: Troubleshooting Scope

- **Decision**: Cover three failure modes with discrete diagnostic steps:
  (a) Tailscale peer offline, (b) `devbox` container not running, (c) `maistodos`
  unreachable (Windows Tailscale not running)
- **Rationale**: These map directly to the three US3 acceptance scenarios.
  Broader network debugging (e.g., firewall rules, WireGuard key rotation) is
  out of scope per the spec assumption that Tailscale is already installed and
  authenticated.
- **Alternatives considered**: A generic "Tailscale troubleshooting" section —
  rejected because the spec is fleet-specific and a generic section would
  dilute the actionable steps.

---

## Decision 5: Sensitive Data Handling

- **Decision**: Use Tailscale MagicDNS hostnames only (e.g., `laptop`,
  `console`) — never raw IP addresses. User accounts referenced by generic
  role (e.g., "your user") or omitted from examples.
- **Rationale**: FR-009 and the constitution "No secrets in git (PUBLIC REPO)"
  rule. Tailscale MagicDNS names are safe to publish: they do not expose
  infrastructure topology beyond what is already in the `.ssh/config` (also
  public).
- **Alternatives considered**: Including `tailscale ip -4` output examples —
  rejected because real IPs would violate FR-009.

---

## Decision 6: Port Forwarding Documentation for `devbox`

- **Decision**: Document that `ssh devbox` automatically forwards local port
  3000 to `localhost:3000` inside the container. Note this is intentional for
  web services in the dev environment.
- **Rationale**: FR-004 requires this; the `.ssh/config` `LocalForward 3000
  localhost:3000` line is non-obvious and would surprise a developer seeing
  unexpected port binding.
- **Alternatives considered**: Omit port forwarding details — rejected because
  it would leave a "why is port 3000 open on my machine?" question unanswered.

---

## Source References

| Source | Used for |
|--------|----------|
| `docs/infra.md` (current) | Existing content baseline |
| `.ssh/config` | Authoritative alias definitions (Host, HostName, Port, LocalForward) |
| `docs/devbox.md` | devbox container details |
| `docs/n8n-bazzite.md` | n8n service port and purpose |
