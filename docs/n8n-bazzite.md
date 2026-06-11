# n8n Self-Hosted on Bazzite (Podman + Quadlet)

Replication guide for running n8n on a Bazzite Silverblue host as a rootless,
auto-starting systemd user service, accessed over Tailscale.

## Assumptions

- Host: Bazzite (Fedora Silverblue), Podman ≥ 5.x.
- Single user (`uid=1000`) with `loginctl enable-linger` enabled.
- Tailscale already up; host reachable via MagicDNS hostname (here: `console`).
- Access stays inside the tailnet (HTTP only, no public exposure).
- SQLite (default) as DB.

## 1. Verify host prerequisites

```bash
podman --version                      # >= 5.0
loginctl show-user $USER | grep Linger=yes
ss -tln | grep 5678 || echo "port free"
systemctl --user is-active default.target
tailscale status | head -1
```

If linger is off:

```bash
sudo loginctl enable-linger $USER
```

## 2. Create directories

```bash
mkdir -p ~/.local/share/n8n \
         ~/.local/share/n8n-backup \
         ~/.config/containers/systemd \
         ~/.config/systemd/user \
         ~/.local/bin
```

## 3. Pull image (avoid first-start timeout)

```bash
podman pull docker.io/n8nio/n8n:2.21.7
```

Pin the version. `latest` will silently break workflows on a major bump.

## 4. Quadlet unit

`~/.config/containers/systemd/n8n.container`:

```ini
[Unit]
Description=n8n self-hosted (Quadlet)
After=network-online.target
Wants=network-online.target

[Container]
Image=docker.io/n8nio/n8n:2.21.7
ContainerName=n8n
UserNS=keep-id:uid=1000,gid=1000
PublishPort=5678:5678
Volume=%h/.local/share/n8n:/home/node/.n8n:Z
Environment=TZ=America/Sao_Paulo
Environment=GENERIC_TIMEZONE=America/Sao_Paulo
Environment=N8N_HOST=console
Environment=N8N_PORT=5678
Environment=N8N_PROTOCOL=http
Environment=WEBHOOK_URL=http://console:5678/
Environment=N8N_SECURE_COOKIE=false
Environment=N8N_RUNNERS_ENABLED=true

[Service]
Restart=always
TimeoutStartSec=300

[Install]
WantedBy=default.target
```

Key bits:

- `UserNS=keep-id:uid=1000,gid=1000` — maps the container's `node` user
  (uid 1000) onto the host's uid 1000. Without it the bind mount appears as
  `nobody` inside the container and n8n exits with
  `EACCES: permission denied, open '/home/node/.n8n/config'`.
- `:Z` — SELinux relabel for the bind mount (Bazzite is enforcing).
- `N8N_SECURE_COOKIE=false` — required when accessing over plain HTTP. Flip
  to `true` and switch `N8N_PROTOCOL=https` if you put a TLS proxy in front
  (e.g. `tailscale serve`).
- `WEBHOOK_URL` — must match the externally reachable URL or webhooks come
  back with the wrong host.
- Replace `console` with your Tailscale MagicDNS hostname.

## 5. Backup the encryption key (and everything else)

n8n writes `~/.n8n/config` with an `encryptionKey` on first boot. Lose it →
all stored credentials become unrecoverable. Daily rotating tarball:

`~/.local/bin/n8n-backup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC="$HOME/.local/share/n8n"
DST="$HOME/.local/share/n8n-backup"
KEEP=7
mkdir -p "$DST"
TS=$(date +%Y%m%d-%H%M%S)
OUT="$DST/n8n-${TS}.tar.gz"
tar -czf "$OUT" -C "$HOME/.local/share" n8n
ls -1t "$DST"/n8n-*.tar.gz | tail -n +$((KEEP + 1)) | xargs -r rm -f
echo "backup: $OUT"
```

```bash
chmod +x ~/.local/bin/n8n-backup.sh
```

`~/.config/systemd/user/n8n-backup.service`:

```ini
[Unit]
Description=Backup n8n data (tar.gz, rotates last 7)
After=n8n.service

[Service]
Type=oneshot
ExecStart=%h/.local/bin/n8n-backup.sh
```

`~/.config/systemd/user/n8n-backup.timer`:

```ini
[Unit]
Description=Daily n8n backup

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
```

Off-host copy: point `restic` / `rclone` at `~/.local/share/n8n-backup/`.
Local tarballs alone do not survive a disk failure.

## 6. Start everything

```bash
systemctl --user daemon-reload
systemctl --user start n8n.service
systemctl --user enable --now n8n-backup.timer

systemctl --user status n8n.service --no-pager
systemctl --user list-timers n8n-backup.timer
curl -sI http://localhost:5678   # expect HTTP/1.1 200 OK
```

Quadlet generates `n8n.service` from `n8n.container` on every
`daemon-reload`. You do not write the `.service` file yourself, and
`systemctl --user enable n8n.service` is not needed — `WantedBy=default.target`
in the unit and `loginctl enable-linger` together give boot-time autostart.

Open `http://console:5678` (or `http://<tailscale-ip>:5678`) and create the
owner account.

## 7. Operations

| Task | Command |
|---|---|
| View logs | `journalctl --user -u n8n.service -f` |
| Restart | `systemctl --user restart n8n.service` |
| Stop | `systemctl --user stop n8n.service` |
| Update image | edit tag in unit → `daemon-reload` → `restart` |
| Force pull new tag | `podman pull docker.io/n8nio/n8n:<tag>` |
| List backups | `ls -lh ~/.local/share/n8n-backup/` |
| Manual backup | `systemctl --user start n8n-backup.service` |
| Inspect container | `podman exec -it n8n sh` |

## 8. Restore from backup

```bash
systemctl --user stop n8n.service
rm -rf ~/.local/share/n8n
tar -xzf ~/.local/share/n8n-backup/n8n-<TS>.tar.gz -C ~/.local/share
systemctl --user start n8n.service
```

The encryption key inside the restored `config` file must match the one used
when credentials were saved. Restoring `database.sqlite` without the original
`config` is useless.

## 9. Troubleshooting

- **`EACCES: permission denied … /home/node/.n8n/config`** — missing
  `UserNS=keep-id:uid=1000,gid=1000`. Bind-mounted volume is owned by host
  uid 1000 but rootless podman maps container uid 1000 into the subuid
  range. `keep-id` reverses that.
- **`SELinux` denials on the volume** — confirm `:Z` is on the `Volume=`
  line; check `ausearch -m AVC -ts recent`.
- **Webhooks return the wrong hostname** — `WEBHOOK_URL` must equal the URL
  clients actually hit. Re-set and restart.
- **Browser refuses login cookie** — `N8N_SECURE_COOKIE=true` over plain
  HTTP. Either drop to `false` or put HTTPS in front.
- **Port already in use** — `ss -tlnp | grep 5678`; change `PublishPort`.
- **Service flapping on boot** — check `tailscale0` is up before n8n needs
  it; `After=network-online.target` covers the kernel link but Tailscale
  comes up async. Usually harmless thanks to `Restart=always`.

## 10. Future: HTTPS via Tailscale Serve

```bash
sudo tailscale serve --bg --https=443 http://localhost:5678
```

Then flip:

```ini
Environment=N8N_PROTOCOL=https
Environment=N8N_PORT=443
Environment=WEBHOOK_URL=https://console.<tailnet>.ts.net/
Environment=N8N_SECURE_COOKIE=true
```

Restart the service. Cert is issued and renewed by Tailscale automatically.
