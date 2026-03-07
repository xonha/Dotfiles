# Dotfiles

## Bazzite Development Container Setup

This repository includes a `Dockerfile` for creating an Arch Linux development container (`devbox`) on Bazzite with automatic startup.

### Prerequisites

- Bazzite machine with Podman installed
- SSH access to the Bazzite machine
- User account with sudo privileges (if needed)

### Container Specifications

- **Base Image:** Arch Linux (latest)
- **Container Name:** `devbox`
- **Hostname:** `devbox`
- **Memory Limit:** 14GB RAM + 14GB Swap
- **User:** `henrique` (root-equivalent, UID 0, GID 0)
- **Password:** `plambas`
- **Workspace:** `~/devbox/workspace` mounted at `/workspace` in container
- **Auto-start:** Enabled via systemd user service

### Installed Packages

- base-devel (build tools: gcc, make, etc.)
- git, curl, wget, openssh
- sudo, neovim, less, which
- unzip, zip, ca-certificates
- python, python-pip
- nodejs, npm

### Setup Instructions

#### 1. Build the Container Image

```bash
# On the Bazzite machine
mkdir -p "$HOME/devbox-image" "$HOME/devbox/workspace"

# Copy Dockerfile to the build directory
cat > "$HOME/devbox-image/Dockerfile" <<'EOF'
FROM archlinux:latest

# Keep package metadata fresh and install common development tools.
RUN pacman -Sy --noconfirm \
    && pacman -S --noconfirm --needed \
        base-devel \
        git \
        curl \
        wget \
        openssh \
        sudo \
        neovim \
        less \
        which \
        unzip \
        zip \
        ca-certificates \
        python \
        python-pip \
        nodejs \
        npm \
    && pacman -Scc --noconfirm

# Create a root-equivalent development user named henrique.
ARG USERNAME=henrique
RUN useradd -m -o -u 0 -g 0 -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:plambas" | chpasswd

USER ${USERNAME}
WORKDIR /workspace

# Keep the container alive for shell-based development.
CMD ["sleep", "infinity"]
EOF

# Build the image
podman build -t devbox:latest "$HOME/devbox-image"
```

#### 2. Create and Configure the Container

```bash
# Remove any existing devbox container
podman rm -f devbox >/dev/null 2>&1 || true

# Create the container with resource limits
podman create \
    --name devbox \
    --hostname devbox \
    --memory 14g \
    --memory-swap 14g \
    --pids-limit 4096 \
    -v "$HOME/devbox/workspace:/workspace:Z" \
    -w /workspace \
    localhost/devbox:latest
```

#### 3. Enable Auto-Start with Systemd

```bash
# Generate systemd service file
podman generate systemd --new --name devbox --files

# Move service file to user systemd directory
mkdir -p "$HOME/.config/systemd/user"
mv -f container-devbox.service "$HOME/.config/systemd/user/devbox.service"

# Reload systemd and enable the service
systemctl --user daemon-reload
systemctl --user enable --now devbox.service

# Enable linger so the service starts at boot (even before login)
loginctl enable-linger $USER
```

#### 4. Verify Setup

```bash
# Check service status
systemctl --user status devbox.service

# Check container is running
podman ps --filter name=devbox

# Verify memory limits
podman inspect devbox --format 'Memory={{.HostConfig.Memory}} MemorySwap={{.HostConfig.MemorySwap}}'

# Test access
podman exec -it devbox whoami
```

### Accessing the Container

```bash
# From the Bazzite host
podman exec -it devbox bash

# Or from a remote machine (after SSH to Bazzite)
ssh henrique@<bazzite-ip>
podman exec -it devbox bash
```

### Managing the Service

```bash
# Check status
systemctl --user status devbox.service

# Restart the container
systemctl --user restart devbox.service

# Stop the container
systemctl --user stop devbox.service

# Start the container
systemctl --user start devbox.service

# Disable auto-start
systemctl --user disable devbox.service

# View logs
journalctl --user -u devbox.service -f
```

### Rebuilding After Changes

If you modify the `Dockerfile`:

```bash
# Rebuild the image
podman build --no-cache -t devbox:latest "$HOME/devbox-image"

# Restart the service (it will use the new image due to --new flag)
systemctl --user restart devbox.service
```

### Troubleshooting

**Container won't start:**
- Check logs: `journalctl --user -u devbox.service -n 50`
- Verify image exists: `podman images | grep devbox`
- Check if old container is running: `podman ps -a | grep devbox`

**Service doesn't start at boot:**
- Verify linger is enabled: `loginctl show-user $USER -p Linger`
- Should show `Linger=yes`
- Enable if needed: `loginctl enable-linger $USER`

**Memory limits not applied:**
- Verify with: `podman inspect devbox | grep -i memory`
- Note: CPU pinning (`--cpuset-cpus`) requires rootful Podman

### Notes for AI Agents

When replicating this setup:
1. Use the exact `Dockerfile` content from this repository
2. Execute commands in the order listed
3. Verify each step completes successfully before proceeding
4. Key identifiers: container name = `devbox`, service name = `devbox.service`, user = `henrique`
5. The container uses rootless Podman (user-level systemd service)
6. Memory limit: 14GB is specified as `14g` in Podman arguments
7. The workspace directory must exist before creating the container
8. Linger must be enabled for boot-time startup without user login
