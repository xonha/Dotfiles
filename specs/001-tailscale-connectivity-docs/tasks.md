---

description: "Task list for Tailscale Connectivity Documentation"
---

# Tasks: Tailscale Connectivity Documentation

**Input**: Design documents from `specs/001-tailscale-connectivity-docs/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Not requested — validation is manual per quickstart.md scenarios.

**Organization**: Tasks are grouped by user story. Each story produces an independently
readable and testable section of `docs/infra.md`.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (independent sections or files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Target document: `docs/infra.md`
- Source references: `.ssh/config`, `docs/devbox.md`, `docs/n8n-bazzite.md`

---

## Phase 1: Setup

**Purpose**: Audit the existing document and confirm the data accuracy of all
source files before writing. No content is committed to `docs/infra.md` yet.

- [x] T001 Read `docs/infra.md` and identify every section that is missing,
  incomplete, or inconsistent with the 9 functional requirements in `specs/001-tailscale-connectivity-docs/spec.md`.
  Produce a gap list (mental or written note) to guide the phases below.

- [x] T002 Read `.ssh/config`, `docs/devbox.md`, and `docs/n8n-bazzite.md` to
  confirm the data that will go into the doc: alias names, ports, services,
  and any quirks. Record any discrepancy between those files and the current
  `docs/infra.md`.

---

## Phase 2: Foundational

**Purpose**: Establish the document skeleton — final heading order and section
stubs. This determines the shape every subsequent phase writes into and MUST
be done before any section is populated.

**⚠️ CRITICAL**: User story phases (Phase 3+) write into this skeleton. Do not
skip to content before the structure is in place.

- [x] T003 Rewrite `docs/infra.md` with the final section skeleton in this
  order: Quick Reference → Machines → Tailscale → Per-Machine Details →
  Services on console → Troubleshooting. Preserve any content that still
  applies; leave section bodies as stubs where content will be filled in
  Phase 3+. Commit the skeleton so subsequent phases have a stable base.

**Checkpoint**: Skeleton in place — user story phases can now proceed.

---

## Phase 3: User Story 1 - SSH Alias Quick Reference (Priority: P1) 🎯 MVP

**Goal**: A developer can find the SSH alias table in the first screenful of
`docs/infra.md` and connect to any alias target without additional lookups.

**Independent Test**: Open `docs/infra.md` cold. Locate the alias table.
Run `ssh laptop`, `ssh maistodos`, `ssh devbox` — all three succeed within
2 minutes of opening the doc. See `quickstart.md` Scenario 1.

### Implementation for User Story 1

- [x] T004 [US1] Write the Quick Reference section in `docs/infra.md`:
  a Markdown table with columns Alias / Resolves to / Port / Notes covering
  all four targets — `laptop` (laptop:22), `maistodos` (maistodos:22),
  `devbox` (console:2222), and `console` (console:22 direct). Each row
  must include the `ssh <alias>` command inline or immediately below the table.

- [x] T005 [US1] Add a `devbox` callout in the Quick Reference section of
  `docs/infra.md` explaining that `ssh devbox` automatically forwards local
  port 3000 to `localhost:3000` inside the container. Note this is intentional
  for web services running in the dev environment.

- [x] T006 [US1] Add a `console` direct-access note in `docs/infra.md`
  explaining that no named alias exists for `console` in `.ssh/config` and
  providing the direct command (`ssh <user>@console` via Tailscale MagicDNS).
  Note that if `console` is added to `~/.ssh/config`, `stow .` re-deploys
  it automatically.

**Checkpoint**: SSH alias table present in first screenful; devbox port-forward
and console direct-access quirks documented. User Story 1 independently testable.

---

## Phase 4: User Story 2 - Network Topology (Priority: P2)

**Goal**: A reader unfamiliar with the fleet can name each machine's role,
list all services on `console`, and understand how Tailscale MagicDNS connects
everything — after a single read-through.

**Independent Test**: See `quickstart.md` Scenario 2. Reader answers three
questions correctly without re-reading.

### Implementation for User Story 2

- [x] T007 [P] [US2] Write the Machines section in `docs/infra.md`: a roster
  table with columns Host / Hardware / OS / Role for `laptop` (ThinkPad,
  Arch Linux, primary client), `console` (Desktop PC, Bazzite, home server),
  and `maistodos` (Work PC, Windows + Arch WSL2, work machine).

- [x] T008 [P] [US2] Write the Tailscale section in `docs/infra.md`:
  explain that MagicDNS resolves hostnames across all machines (no IP addresses
  needed for routine work) and include the two diagnostic commands:
  `tailscale ip -4` and `tailscale status`.

- [x] T009 [US2] Write the Per-Machine Details section in `docs/infra.md`
  with one subsection per machine covering any topology quirks not in the
  roster table. Specifically: `maistodos` must explain that Tailscale runs on
  the Windows host and WSL2 is reachable through the Windows Tailscale address.
  Depends on T007 and T008.

- [x] T010 [US2] Write the Services on console section in `docs/infra.md`:
  a table with columns Container / Port / Purpose covering `devbox` (SSH 2222,
  Arch Linux dev environment) and `n8n` (5678, workflow automation). Link to
  `docs/devbox.md` and `docs/n8n-bazzite.md` for deeper detail. Depends on T009.

**Checkpoint**: Machines, Tailscale, per-machine quirks, and services all
documented. User Story 2 independently testable.

---

## Phase 5: User Story 3 - Troubleshooting (Priority: P3)

**Goal**: A developer who cannot connect identifies the root cause and recovers
using only the troubleshooting section — zero external searches for the three
common failure modes.

**Independent Test**: See `quickstart.md` Scenarios 3 and 4.

### Implementation for User Story 3

- [x] T011 [US3] Write the Troubleshooting section in `docs/infra.md` covering
  three discrete failure modes, each with a symptom, diagnostic command, and
  recovery step:

  1. **Peer offline** — `tailscale status` shows a machine as offline.
     Diagnostic: check Tailscale is running on the remote host.
     Recovery: start Tailscale on the remote.

  2. **devbox container not running** — `ssh devbox` times out or refuses.
     Diagnostic: SSH into `console` directly and run
     `systemctl --user status devbox` (or the equivalent service name).
     Recovery: `systemctl --user start devbox`.

  3. **maistodos unreachable** — `ssh maistodos` times out.
     Diagnostic: verify Tailscale is running on the **Windows host** (system
     tray), not just in WSL2 — Tailscale in WSL2 alone does not expose the
     machine to the Tailscale network.
     Recovery: start or resume Tailscale from the Windows system tray.

  4. **console powered off** — both `ssh devbox` and direct `console` access
     fail simultaneously.
     Diagnostic: `tailscale status` shows `console` as offline (not just the
     devbox container). This is distinct from the container-stopped case.
     Recovery: power on `console`; all hosted services (devbox, n8n) resume
     automatically via their systemd user services.

**Checkpoint**: Troubleshooting section complete. User Story 3 independently testable.

---

## Phase 6: Polish & Validation

**Purpose**: Safety checks and final quality pass.

- [x] T012 [P] Run the public-safety spot-check from `quickstart.md` Scenario 5
  against `docs/infra.md`:
  ```bash
  grep -Ei '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' docs/infra.md
  grep -Ei 'password|token|secret|api.?key|ssh-rsa|BEGIN.*PRIVATE' docs/infra.md
  grep -Ei '@[a-z]+\.[a-z]+' docs/infra.md
  ```
  All three commands MUST return zero matches. Fix any leaks found.

- [x] T013 [P] Verify `docs/infra.md` is still linked from `CLAUDE.md` under
  the Index section (it should already be — confirm no link was broken during
  the rewrite in T003).

- [x] T014 Scroll `docs/infra.md` in a terminal or browser and confirm the
  SSH alias table (Quick Reference section) is visible within the first
  screenful without scrolling. If not, move or restructure the section.
  Depends on T012, T013.

- [x] T015 Run the full quickstart validation from `specs/001-tailscale-connectivity-docs/quickstart.md`
  (all 5 scenarios) and mark each checklist item in that file as done.
  Depends on T014.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion
- **User Stories (Phases 3–5)**: All depend on Phase 2 (skeleton); each
  user story phase is otherwise independent of the others
- **Polish (Phase 6)**: Depends on all user story phases completing

### User Story Dependencies

- **US1 (P1, Phase 3)**: Can start after Phase 2 — no dependency on US2 or US3
- **US2 (P2, Phase 4)**: Can start after Phase 2 — T007 and T008 are parallel;
  T009 depends on T007+T008; T010 depends on T009
- **US3 (P3, Phase 5)**: Can start after Phase 2 — no dependency on US1 or US2

### Within User Story 2

- T007 and T008 are [P] — different sections, no dependency on each other
- T009 depends on T007 and T008 (references both sections)
- T010 depends on T009 (services subsection follows per-machine details)

### Parallel Opportunities

```bash
# After Phase 2 (skeleton done), three phases can start in parallel:
Task: "T004 [US1] Quick Reference table in docs/infra.md"
Task: "T007 [P] [US2] Machines section in docs/infra.md"
Task: "T008 [P] [US2] Tailscale section in docs/infra.md"

# Phase 6 safety checks run in parallel:
Task: "T012 [P] Public-safety grep checks"
Task: "T013 [P] Verify CLAUDE.md link"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational skeleton (T003)
3. Complete Phase 3: SSH alias quick reference (T004–T006)
4. **STOP and VALIDATE**: `quickstart.md` Scenario 1 — SSH to all aliases in under 2 min
5. Ship if alias reference is sufficient for immediate needs

### Incremental Delivery

1. Setup + Skeleton → foundation ready
2. US1 → SSH quick reference → validate → ship (MVP)
3. US2 → topology reference → validate → ship
4. US3 → troubleshooting → validate → ship
5. Polish → full quickstart pass → done

---

## Notes

- [P] tasks = independent content sections or checks with no cross-task file conflicts
- [Story] label maps each task to its user story for traceability
- All tasks target `docs/infra.md` as the single output file — ensure no two
  tasks in the same phase write to the same section simultaneously
- No tests are generated (not requested); validation is done via `quickstart.md`
- The `console` direct-access note (T006) is additive — the SSH alias for
  `console` does not exist in `.ssh/config` today and should not be added here
  without a separate feature to update that file
