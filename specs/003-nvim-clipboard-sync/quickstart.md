# Quickstart Validation Guide: Neovim Clipboard Sync

**Date**: 2026-06-18
**Feature**: specs/003-nvim-clipboard-sync

## Prerequisites

- Neovim installed and configured via this dotfiles repo
- Running a Wayland session (Hyprland)
- `wl-clipboard` installed (`which wl-copy wl-paste` should both resolve)
- Dotfiles deployed: `stow .` run from repo root

## Validation Scenarios

### SC-001 + SC-002: Bidirectional clipboard (primary flows)

**Yank from Neovim → paste outside**

1. Open Neovim with any file: `nvim /tmp/test.txt`
2. Type a unique test string (e.g., `hello_clipboard_test`)
3. In normal mode, press `yy` to yank the line
4. Open a browser or another terminal
5. Press Ctrl+V (or middle-click) — the yanked text should appear

Expected: `hello_clipboard_test` pasted without extra steps.

**Copy outside → paste in Neovim**

1. Select any text in a browser or terminal and press Ctrl+C
2. Switch to Neovim (normal mode)
3. Press `p`

Expected: the copied text inserted into the buffer.

### SC-003: Named registers unaffected

1. In Neovim, yank a line to a named register: `"ayy`
2. Copy different text in the browser via Ctrl+C
3. In Neovim, press `"ap` — the **originally yanked** text should paste (not the browser text)

Expected: named register `a` preserves its own content independently of the system clipboard.

### SC-004: Clipboard persists after Neovim closes

1. Open Neovim, yank a line: `yy`
2. Close Neovim: `:qa`
3. Open a browser, press Ctrl+V

Expected: the yanked text is still available and pastes correctly.

### SC-005: Fresh machine — clipboard works out of the box

1. Confirm `wl-clipboard` is present in `.setup/desktop.sh` `PKG_DESKTOP` array
2. Simulate: `which wl-copy wl-paste` — both resolve
3. Open Neovim, run `:checkhealth` and look for the clipboard section

Expected: `:checkhealth` reports clipboard provider found (`wl-copy`) with no errors.

## Quick Sanity Check (terminal only)

```bash
# Verify wl-clipboard tools are available
which wl-copy wl-paste

# Verify Neovim clipboard option is set
nvim --headless -c 'echo &clipboard' -c 'q' 2>&1
# Expected output: unnamedplus
```

## Known Non-Issues

- Inside a tmux session, clipboard sync may not work — this is a tmux limitation and is out of scope for this feature.
- Visual selection in Neovim does NOT write to PRIMARY selection (middle-click buffer) — this is intentional; `unnamedplus` targets CLIPBOARD only for predictable behaviour.
