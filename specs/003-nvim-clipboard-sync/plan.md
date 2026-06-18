# Implementation Plan: Neovim Clipboard Sync

**Branch**: `003-nvim-clipboard-sync` | **Date**: 2026-06-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-nvim-clipboard-sync/spec.md`

## Summary

Neovim currently uses an isolated unnamed register for yank/paste, disconnected from the OS CLIPBOARD. Setting `vim.opt.clipboard = "unnamedplus"` in the Neovim options config unifies the default register with the system clipboard, enabling seamless copy-paste between Neovim and other Wayland apps. The required clipboard provider (`wl-clipboard`) is already installed via `desktop.sh`.

## Technical Context

**Language/Version**: Lua (Neovim config)

**Primary Dependencies**: Neovim + LazyVim; `wl-clipboard` (already in `PKG_DESKTOP`)

**Storage**: N/A

**Testing**: Manual — yank in Neovim → paste in browser; copy in browser → paste in Neovim

**Target Platform**: Arch Linux, Wayland/Hyprland (desktop layer)

**Project Type**: Dotfiles configuration

**Performance Goals**: No measurable impact — option is set once at startup with no ongoing overhead

**Constraints**: Must follow Stow layout (Principle I); must be deployed via `stow .`; no undocumented manual steps (Principle II)

**Scale/Scope**: Single developer workstation; one file change

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Stow-First Layout | ✅ PASS | Change is to `.config/nvim/lua/config/options.lua` — a tracked dotfile at its `$HOME`-relative path |
| II. Reproducible From Bare Metal | ✅ PASS | `wl-clipboard` already in `PKG_DESKTOP`; no new installer step needed |
| III. Idempotent & Re-Runnable | ✅ PASS | `stow .` re-runs safely; option file is idempotent |
| IV. Server Base, Desktop Additive | ✅ PASS | `wl-clipboard` is in the desktop layer (not server); Neovim config is desktop-only in practice |
| V. Machine-Specific Stays Untracked | ✅ PASS | No machine-specific data introduced |
| No Secrets | ✅ PASS | No credentials or sensitive data |

**Post-design re-check**: All gates still pass. The single-line Lua change introduces no new complexity or violations.

## Project Structure

### Documentation (this feature)

```text
specs/003-nvim-clipboard-sync/
├── plan.md              # This file
├── research.md          # Phase 0 — clipboard mechanism decisions
├── quickstart.md        # Phase 1 — validation guide
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
.config/nvim/
└── lua/
    └── config/
        └── options.lua    # ADD: vim.opt.clipboard = "unnamedplus"

.setup/
└── desktop.sh             # NO CHANGE — wl-clipboard already in PKG_DESKTOP
```

## Implementation Steps

### Step 1 — Add clipboard option to Neovim config

**File**: `.config/nvim/lua/config/options.lua`

Add one line:

```lua
vim.opt.clipboard = "unnamedplus"
```

This makes Neovim's unnamed register (`"`) and the `+` register point to the OS CLIPBOARD. All standard yank/paste operations (`yy`, `p`, `dd`, etc.) will transparently use the system clipboard. Named registers (`"a`–`"z`) are unaffected.

### Step 2 — Verify `wl-clipboard` is present

**File**: `.setup/desktop.sh` — already contains `wl-clipboard` in `PKG_DESKTOP`. No change needed.

Confirm: `which wl-copy wl-paste` on the target machine should both resolve.

### Step 3 — Deploy via stow

From the repo root:

```bash
stow .
```

This re-creates the symlink for `~/.config/nvim/lua/config/options.lua` (or updates it in place). No Neovim restart required if done before launching Neovim; otherwise restart Neovim.

### Step 4 — Validate

See `quickstart.md` for the full validation checklist.

## Complexity Tracking

*No constitution violations — section not applicable.*
