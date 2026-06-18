# Research: Neovim Clipboard Sync

**Date**: 2026-06-18
**Feature**: specs/003-nvim-clipboard-sync

## Decision 1: Neovim clipboard integration mechanism

**Decision**: Set `vim.opt.clipboard = "unnamedplus"` in `lua/config/options.lua`.

**Rationale**: Neovim's `clipboard` option controls which OS registers the unnamed register (`"`) is linked to. Two values matter on Linux:
- `"unnamed"` — syncs with `*` (X11 PRIMARY selection; middle-click)
- `"unnamedplus"` — syncs with `+` (CLIPBOARD; Ctrl+C / Ctrl+V)

Setting `clipboard = "unnamedplus"` makes every yank (`yy`, `y`, `d`, `c`) write to the system CLIPBOARD, and every paste (`p`, `P`) read from it. This is the standard approach used by the majority of LazyVim users on Wayland.

**Alternatives considered**:
- `"unnamed,unnamedplus"` (both registers) — also valid, but syncing with the PRIMARY selection means any accidental visual selection in Neovim overwrites what you copied in another app. The CLIPBOARD (`unnamedplus`) alone is the more predictable choice.
- A custom keymap (e.g., `<leader>y` copies to `+`) — requires extra keystrokes per the spec's FR requirements, ruled out.
- Plugin (e.g., `vim-oscyank`) — unnecessary; Neovim's built-in clipboard provider handles Wayland correctly when `wl-clipboard` is present.

## Decision 2: System clipboard daemon / provider

**Decision**: Rely on `wl-clipboard` (`wl-copy` / `wl-paste`) already installed via `desktop.sh`.

**Rationale**: Neovim auto-detects clipboard providers at startup by checking `$PATH` for known binaries. On Wayland the priority order is: `wl-copy` → `xclip` → `xsel`. Since `wl-clipboard` is already in `PKG_DESKTOP` in `.setup/desktop.sh` (line 65), no installer change is required. The package is present on every machine that runs the desktop layer.

**Alternatives considered**:
- `xclip` — X11 only, not reliable under pure Wayland/Hyprland.
- `xsel` — same limitation.
- `wl-clipboard-rs` (AUR) — not needed; upstream `wl-clipboard` is fully sufficient.

## Decision 3: Named registers and LazyVim defaults

**Decision**: No changes to named registers or LazyVim's default keymap.

**Rationale**: `vim.opt.clipboard = "unnamedplus"` only affects the unnamed (`"`) and `+` registers. Named registers (`"a`–`"z`, `"0`–`"9`) continue to work independently. LazyVim does not set `clipboard` by default (it leaves it empty), so this single option line is the only change needed to the Neovim config.

**Verification**: Checked `lua/config/options.lua` — the file is currently a no-op comment stub. No existing clipboard override to conflict with.

## Decision 4: tmux clipboard passthrough

**Decision**: Out of scope (per spec Assumptions).

**Rationale**: Inside a tmux session, `wl-clipboard` may not be reachable from the inner process because `$WAYLAND_DISPLAY` is sometimes unset for panes created before the Wayland session was established. This is a tmux-specific issue that affects all clipboard operations inside tmux, not just Neovim. The spec explicitly marks this as out of scope. Users should use `tmux-yank` plugin or re-export `$WAYLAND_DISPLAY` if they want tmux support — that is a separate feature.

## Summary of changes required

| File | Change |
|------|--------|
| `.config/nvim/lua/config/options.lua` | Add `vim.opt.clipboard = "unnamedplus"` |
| `.setup/desktop.sh` | No change — `wl-clipboard` already present |
