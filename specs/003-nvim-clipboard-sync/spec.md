# Feature Specification: Neovim Clipboard Sync

**Feature Branch**: `003-nvim-clipboard-sync`

**Created**: 2026-06-18

**Status**: Draft

**Input**: User description: "my neovim config currently does not share the clipboard with my system, meaning what i copy with yank (yy) is not the same as me mouse selecting and ctrl+c, can we unify it?"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Yank in Neovim, Paste Anywhere (Priority: P1)

The developer yanks text inside Neovim (using `yy`, `y`, or any yank operation) and can immediately paste it in any other application — browser, terminal emulator, file manager, or chat app — using the standard system paste shortcut (Ctrl+V or middle-click).

**Why this priority**: This is the primary pain point described. Without this, the developer must resort to mouse-selection workarounds to move text out of Neovim, breaking their editing flow.

**Independent Test**: Open Neovim, yank a line with `yy`, switch to a browser address bar, press Ctrl+V — the yanked text appears.

**Acceptance Scenarios**:

1. **Given** Neovim is open with a file, **When** the developer yanks any text with a yank operator, **Then** that text is available via the system paste shortcut in any other application immediately after.
2. **Given** the developer yanked text in Neovim, **When** they middle-click in another terminal window, **Then** the yanked text is pasted.
3. **Given** the developer yanked text in Neovim, **When** they reopen Neovim in a different split or pane, **Then** the text is also pasteable inside Neovim via standard paste.

---

### User Story 2 - Copy Outside Neovim, Paste Inside (Priority: P1)

The developer selects and copies text in any external application (browser, terminal, document) using Ctrl+C or Ctrl+Shift+C, then pastes it inside Neovim using the standard Neovim paste command (`p` or `P`).

**Why this priority**: Bidirectional clipboard is required for a seamless workflow. Copy-paste in one direction only is still a broken experience.

**Independent Test**: Copy a URL from the browser (Ctrl+C), switch to Neovim, press `p` in normal mode — the URL appears in the buffer.

**Acceptance Scenarios**:

1. **Given** text is copied in an external application via Ctrl+C, **When** the developer presses `p` inside Neovim, **Then** the copied text is pasted into the buffer.
2. **Given** the developer selects text by mouse in another terminal and it goes to the primary selection, **When** they press the system paste shortcut inside Neovim, **Then** that selected text is inserted.

---

### User Story 3 - Clipboard Persists Across Neovim Sessions (Priority: P2)

Text yanked in a previous Neovim session is still accessible from the system clipboard after Neovim is closed, so the developer can use it in other applications without needing Neovim to remain open.

**Why this priority**: A common workflow is to yank something, close Neovim, then paste it elsewhere. If the clipboard dies with the process, the developer loses the text.

**Independent Test**: Yank a line in Neovim, close Neovim entirely, open a browser, press Ctrl+V — the yanked text appears.

**Acceptance Scenarios**:

1. **Given** the developer yanked text in Neovim, **When** Neovim is closed, **Then** the text remains available via the system clipboard for at least one subsequent paste in another application.

---

### Edge Cases

- What happens when the developer yanks to a named register (e.g., `"ayy`) — does the named register still work independently from the system clipboard?
- How does the system clipboard behave during a terminal multiplexer session (e.g., tmux) where the Neovim process may be detached?
- What happens if clipboard support is unavailable (clipboard daemon not running) — does Neovim continue to work normally with local registers?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Yanking any text in Neovim MUST synchronise that text to the operating system clipboard so it is immediately available for pasting in other applications.
- **FR-002**: Text copied in any external application MUST be pasteable inside Neovim using standard Neovim paste commands without any additional steps.
- **FR-003**: Named registers (e.g., `"a`, `"b`) MUST continue to work independently and MUST NOT be overwritten by the system clipboard sync.
- **FR-004**: The clipboard sync MUST work without degrading Neovim startup time or editing responsiveness.
- **FR-005**: The configuration change MUST be deployed via the existing Stow-managed dotfiles mechanism with no manual steps.
- **FR-006**: Any system-level dependency required to support clipboard integration MUST be added to the reproducible installer so a fresh machine setup includes it automatically.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The developer can yank text in Neovim and paste it in another application in under 5 seconds with no extra steps beyond the yank itself.
- **SC-002**: The developer can copy text in an external application and paste it into Neovim in under 5 seconds with no extra steps beyond the copy itself.
- **SC-003**: All existing Neovim yank/paste workflows (named registers, visual selection yank, delete-to-register) continue to behave as expected after the change.
- **SC-004**: The clipboard remains accessible after Neovim is closed, so at least one subsequent paste in another application succeeds.
- **SC-005**: A fresh machine provisioned with the installer has clipboard integration working out of the box with no post-install manual steps.

## Assumptions

- The desktop environment is Wayland-based (Hyprland), as defined in the dotfiles. X11 clipboard tooling is not required.
- The developer uses the standard Neovim yank commands (`y`, `yy`, `Y`, `d`, `c`) and expects them all to sync with the system clipboard.
- LazyVim is the Neovim distribution in use; its default clipboard settings may need to be overridden or supplemented.
- Mouse-primary-selection (middle-click paste) should also be covered under "system clipboard", as this is the user's mentioned use case.
- The tmux session clipboard behaviour is a known limitation of terminal multiplexers and is out of scope for this feature unless trivially solvable.
- The solution must not require the developer to use a separate register (e.g., `"+yy`) for every yank — the default unnamed register and the system clipboard must be unified.
