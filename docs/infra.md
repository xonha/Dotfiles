# Local Dev Infrastructure

All machines connected via Tailscale MagicDNS.

## Machines

| Host | Hardware | OS | Role |
|------|----------|----|------|
| `laptop` | ThinkPad | Arch Linux | Primary client — Hyprland desktop |
| `console` | Desktop PC | Bazzite (Fedora Silverblue) | Home server — runs containers |
| `maistodos` | Work PC | Windows + Arch WSL | Work machine |

## Tailscale

MagicDNS resolves hostnames across all machines. No need for IP addresses.

```bash
tailscale ip -4          # get this machine's IP
tailscale status         # show all peers
```

## SSH Aliases (`~/.ssh/config`)

| Alias | Resolves to | Notes |
|-------|-------------|-------|
| `laptop` | `laptop` (Tailscale) | Arch desktop |
| `maistodos` | `maistodos` (Tailscale) | Work PC (Arch WSL) |
| `devbox` | `console:2222` | Arch container on Bazzite; forwards port 3000 locally |

```bash
ssh laptop       # ThinkPad
ssh maistodos    # work machine
ssh devbox       # Arch devbox on console (port 2222, local forward :3000)
```

## console — Bazzite Host

Runs rootless Podman containers as systemd user services:

| Container | Port | Purpose |
|-----------|------|---------|
| `devbox` | `2222` (SSH) | Arch Linux dev environment |
| n8n | `5678` | Workflow automation (see [n8n doc](n8n-bazzite.md)) |

Access console directly:

```bash
ssh console      # Bazzite host (add alias to ~/.ssh/config if needed)
```

## maistodos — Work Machine (Arch WSL)

Windows host running Arch Linux under WSL2. Tailscale runs on the Windows side; WSL is reachable via the Windows Tailscale IP or by SSHing into the Windows host and forwarding.

## Typical Workflow

- Code on `laptop` (Arch, local editor) or inside `devbox` (SSH + Neovim).
- Services on `console` accessible from any machine via Tailscale.
- Work tasks on `maistodos` (WSL Arch for dev, Windows for meetings/Office).
