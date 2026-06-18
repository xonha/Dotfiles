---
description: "Task list for Neovim Clipboard Sync"
---

# Tasks: Neovim Clipboard Sync

**Input**: Design documents from `specs/003-nvim-clipboard-sync/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | quickstart.md ✅

**Organization**: Tasks are grouped by user story to enable independent validation of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup (Prerequisites)

**Purpose**: Confirm the system foundation is in place before making any config changes.

- [x] T001 Verify `wl-copy` and `wl-paste` are in PATH on the target machine (`which wl-copy wl-paste`)
- [x] T002 Confirm current broken state: open Neovim, run `:checkhealth` and note the clipboard provider section, then yank a line (`yy`) and confirm it does NOT paste outside Neovim

**Checkpoint**: Prerequisites confirmed — `wl-clipboard` present, broken behaviour documented.

---

## Phase 2: Foundational (Core Change — blocks all user stories)

**Purpose**: Apply the single configuration change that satisfies all user stories.

**⚠️ CRITICAL**: No user story validation can begin until this phase is complete.

- [x] T003 Add `vim.opt.clipboard = "unnamedplus"` to `.config/nvim/lua/config/options.lua`
- [x] T004 Deploy the updated config by running `stow .` from the repo root

**Checkpoint**: Foundation ready — Neovim is now configured to use the system clipboard. User story validation can begin.

---

## Phase 3: User Story 1 — Yank in Neovim, Paste Anywhere (Priority: P1) 🎯 MVP

**Goal**: Text yanked in Neovim is immediately available in other applications via the system paste shortcut.

**Independent Test**: Open Neovim, yank a line (`yy`), switch to a browser, press Ctrl+V — yanked text appears.

### Implementation for User Story 1

- [ ] T005 [US1] Restart Neovim (or open a fresh session) to load the updated `options.lua`
- [ ] T006 [US1] Validate yank-to-outside flow: yank a unique string with `yy`, paste in a browser or external terminal with Ctrl+V — confirm the text matches (see `quickstart.md` SC-001)
- [ ] T007 [US1] Validate middle-click paste: yank a line in Neovim, middle-click in another terminal — confirm the text pastes
- [x] T008 [US1] Run the terminal sanity check from `quickstart.md`: `nvim --headless -c 'echo &clipboard' -c 'q'` — confirm output is `unnamedplus`

**Checkpoint**: User Story 1 complete — yank-to-outside clipboard sync works end-to-end.

---

## Phase 4: User Story 2 — Copy Outside Neovim, Paste Inside (Priority: P1)

**Goal**: Text copied in any external application is pasteable inside Neovim with `p` or `P`.

**Independent Test**: Copy a URL from a browser (Ctrl+C), switch to Neovim, press `p` — URL appears in the buffer.

### Implementation for User Story 2

- [ ] T009 [US2] Validate copy-to-inside flow: copy text from browser (Ctrl+C), paste in Neovim normal mode with `p` — confirm text matches (see `quickstart.md` SC-001)
- [ ] T010 [P] [US2] Validate named registers are unaffected: yank to register `a` (`"ayy`), copy different text in browser (Ctrl+C), press `"ap` in Neovim — confirm register `a` still holds the original value (see `quickstart.md` SC-003)

**Checkpoint**: User Story 2 complete — copy-from-outside to Neovim paste works end-to-end. Named registers unaffected confirmed.

---

## Phase 5: User Story 3 — Clipboard Persists After Neovim Closes (Priority: P2)

**Goal**: Text yanked in Neovim remains in the system clipboard after Neovim is closed.

**Independent Test**: Yank a line in Neovim, close Neovim (`:qa`), open browser, press Ctrl+V — text appears.

### Implementation for User Story 3

- [ ] T011 [US3] Validate clipboard persistence: yank a unique string in Neovim, close Neovim with `:qa`, open a browser and paste with Ctrl+V — confirm the yanked text is still available (see `quickstart.md` SC-004)

**Checkpoint**: User Story 3 complete — clipboard contents survive Neovim process exit.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation sweep and documentation confirmation.

- [ ] T012 [P] Run the full `quickstart.md` validation checklist from top to bottom and confirm all 5 scenarios pass (SC-001 through SC-005)
- [ ] T013 [P] Run `:checkhealth` in Neovim and confirm clipboard section now shows `wl-copy` as provider with no warnings

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — **BLOCKS all user story validation**
- **User Stories (Phases 3–5)**: All depend on Phase 2 (Foundational) completion
  - US1 and US2 (both P1) can be validated in parallel after Phase 2
  - US3 (P2) can start after Phase 2; does not depend on US1 or US2
- **Polish (Phase 6)**: Depends on all desired user stories being validated

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 2 — no dependency on US2 or US3
- **User Story 2 (P1)**: Can start after Phase 2 — no dependency on US1 or US3
- **User Story 3 (P2)**: Can start after Phase 2 — no dependency on US1 or US2

### Parallel Opportunities

- T006 and T009 (US1 yank-out vs US2 copy-in validation) can run in parallel after T005
- T010 (named register check) is independent and can run in parallel with T009
- T012 and T013 (final polish) can run in parallel

---

## Parallel Example: User Stories 1 & 2 (after T004)

```bash
# Restart Neovim (T005), then run in parallel:
Task: "Validate yank-to-outside flow" (T006)
Task: "Validate copy-to-inside flow" (T009)
Task: "Validate named registers unaffected" (T010)
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 — both P1)

1. Complete Phase 1: Setup (verify wl-clipboard)
2. Complete Phase 2: Foundational (add clipboard option + stow)
3. Complete Phase 3: User Story 1 validation
4. Complete Phase 4: User Story 2 validation
5. **STOP and VALIDATE**: Both P1 stories confirmed working
6. Ship — clipboard is fully functional for the primary workflows

### Full Delivery (add P2)

1. MVP steps above
2. Complete Phase 5: User Story 3 (clipboard persistence validation)
3. Complete Phase 6: Polish (full quickstart sweep)

---

## Notes

- All user stories share the same single implementation change (T003 + T004) — phases 3–5 are validation-only
- [P] tasks operate independently; no file conflicts possible
- Commit after T003+T004 with a conventional commit: `feat: unify neovim clipboard with system clipboard`
- If T001 fails (wl-clipboard missing), run `yay -S wl-clipboard` — but this should already be covered by `desktop.sh`
- tmux clipboard passthrough is explicitly out of scope — document in `:checkhealth` notes if asked
