# Paperclip — AI Agent Orchestrator on Bazzite

Paperclip is an open-source AI agent orchestration platform. It runs as two
rootless Podman containers (server + PostgreSQL) on `console`, managed by
systemd user services via Podman Quadlet. Access the web UI from any Tailscale
machine at `http://console:3100`.

## Architecture

| Component | Image | Port | Purpose |
|-----------|-------|------|---------|
| `paperclip` | `paperclip-local` (built locally) | 3100 | Web UI + API |
| `paperclip-db` | `postgres:17-alpine` | internal | Database |

Quadlet unit files live in `.config/containers/systemd/` in this dotfiles repo
and are deployed via `stow .`.

## Prerequisites

- Bazzite (or Fedora Silverblue) with rootless Podman 4+ and Quadlet support
- Tailscale active and `console` reachable from other fleet machines
- Dotfiles repo cloned on `console`
- Internet access on `console` (to pull images and clone upstream source)

## First-Time Setup

### 1. Deploy Quadlet Files

```bash
# From the dotfiles repo root on console:
stow .

# Verify symlinks:
ls -la ~/.config/containers/systemd/paperclip*
```

### 2. Build the Paperclip Container Image

The `paperclip-local` image is built from the upstream source — no published
image exists on Docker Hub.

```bash
git clone https://github.com/paperclipai/paperclip.git ~/paperclip-src
cd ~/paperclip-src
podman build -t paperclip-local .
# This takes a few minutes on first build.

# Verify:
podman images | grep paperclip-local

# The source clone can be removed after the build (keep for future rebuilds):
# rm -rf ~/paperclip-src
```

### 3. Create the Data Directory

```bash
mkdir -p ~/.local/share/paperclip
```

### 4. Create the Secrets File

The file `~/.config/containers/systemd/paperclip.env` is loaded by both
container units. It is **never committed to git** (gitignored).

```bash
# Generate strong random secrets:
DB_PASS=$(openssl rand -base64 32)
AUTH_SECRET=$(openssl rand -base64 48)

cat > ~/.config/containers/systemd/paperclip.env <<EOF
POSTGRES_USER=paperclip
POSTGRES_PASSWORD=${DB_PASS}
POSTGRES_DB=paperclip
DATABASE_URL=postgres://paperclip:${DB_PASS}@localhost:5432/paperclip
BETTER_AUTH_SECRET=${AUTH_SECRET}
PORT=3100
SERVE_UI=true
PAPERCLIP_PUBLIC_URL=http://console:3100
PAPERCLIP_DEPLOYMENT_MODE=authenticated
PAPERCLIP_DEPLOYMENT_EXPOSURE=private
EOF

chmod 600 ~/.config/containers/systemd/paperclip.env
```

> **Never use the upstream dev default** `paperclip-dev-secret` for
> `BETTER_AUTH_SECRET`. Always generate a fresh value as shown above.

### 5. Start the Service

```bash
systemctl --user daemon-reload
systemctl --user start paperclip-pod
```

Wait up to 60 seconds for PostgreSQL to become healthy, then verify:

```bash
systemctl --user status paperclip-pod paperclip paperclip-db
```

Navigate to `http://console:3100` from any Tailscale machine — the
onboarding screen should appear.

### 6. Enable Auto-Start on Boot

```bash
systemctl --user enable paperclip-pod paperclip paperclip-db

# Enable linger so user services start without login
# (skip if already set for devbox):
loginctl enable-linger $USER
loginctl show-user $USER | grep Linger   # should show Linger=yes
```

## Access

| From | URL |
|------|-----|
| `laptop` | `http://console:3100` |
| `maistodos` | `http://console:3100` |
| `devbox` | `http://console:3100` (inside container) or `http://localhost:3100` if port-forwarded |

## Service Management

```bash
# Status
systemctl --user status paperclip-pod

# Restart
systemctl --user restart paperclip-pod

# Stop
systemctl --user stop paperclip-pod

# Start
systemctl --user start paperclip-pod

# Logs (server)
journalctl --user -u paperclip -f

# Logs (database)
journalctl --user -u paperclip-db -f
```

## Rebuild After Upstream Update

```bash
cd ~/paperclip-src       # or re-clone if deleted
git pull
podman build --no-cache -t paperclip-local .
systemctl --user restart paperclip-pod
```

## Troubleshooting

### UI not reachable (`Connection refused`)

1. Check pod status: `systemctl --user status paperclip-pod`
2. Check if image exists: `podman images | grep paperclip-local`
   - If missing: re-run the build step (Section 2)
3. Check DB health: `systemctl --user status paperclip-db`
4. Check logs: `journalctl --user -u paperclip -n 50`

### Database not ready (server crashes on startup)

PostgreSQL may still be initialising. Wait 30 seconds and restart:

```bash
systemctl --user restart paperclip-pod
```

### Service not starting after reboot

Verify linger is enabled: `loginctl show-user $USER | grep Linger`
If `Linger=no`, run: `loginctl enable-linger $USER`

### `BETTER_AUTH_SECRET` warning in logs

The service detected the dev default secret. Generate a real one and update
`~/.config/containers/systemd/paperclip.env`, then restart the pod.

### Secrets accidentally committed

If `paperclip.env` was ever committed, rotate all secrets immediately:
generate new values, update the file, restart the pod, and remove the file
from git history.
