# Research: Paperclip on Bazzite

**Phase**: 0 — Outline & Research
**Date**: 2026-06-11
**Status**: Complete

## Summary

All technical decisions resolved via upstream Paperclip repository inspection
(`paperclipai/paperclip` on GitHub). The project ships official Quadlet files
(`docker/quadlet/`), a `docker-compose.yml`, and an `.env.example` — all the
deployment primitives needed are provided upstream. No external research was
required beyond reading these source files.

---

## Decision 1: Container Runtime — Quadlet over Docker Compose

- **Decision**: Use Podman Quadlet (upstream `docker/quadlet/` files)
- **Rationale**: Bazzite ships Podman with Quadlet support. Quadlet integrates
  directly with systemd user services — the same pattern used by `devbox.service`.
  The upstream repo ships `.container` and `.pod` Quadlet unit files ready to use.
  Docker Compose would require installing `docker-compose` or `podman-compose`,
  adding a dependency; Quadlet needs nothing extra on Bazzite.
- **Alternatives considered**:
  - `npx paperclipai onboard` — pulls and runs Node.js directly; not suitable
    for an immutable OS like Bazzite without Distrobox; not containerized.
  - Docker Compose — would work but adds a dependency and doesn't integrate
    with systemd user services as cleanly.

---

## Decision 2: Image Build Strategy — Build Locally from Source

- **Decision**: Build the `paperclip-local` image on `console` from the
  upstream GitHub repository using `podman build`
- **Rationale**: The upstream Quadlet `paperclip.container` uses `Image=paperclip-local`,
  meaning no pre-built image is published to a registry. The `Dockerfile` is
  in the repo root. Building locally ensures the image matches the Quadlet
  config without modification.
- **Alternatives considered**:
  - Modify Quadlet to point to a published image — no official image exists
    on Docker Hub or GHCR as of 2026-06-11.
  - Build image on another machine and transfer — more complex than building
    directly on `console`.

---

## Decision 3: Port — 3100 (Default)

- **Decision**: Use Paperclip's default port 3100
- **Rationale**: Port 3100 does not conflict with existing services on `console`
  (`devbox` on 2222, `n8n` on 5678). The upstream `paperclip.pod` Quadlet
  already publishes `3100:3100`. Keeping the default avoids patching upstream
  files.
- **Alternatives considered**: Custom port — unnecessary; default is clean.

---

## Decision 4: Secrets Strategy — Local `.env` File, Gitignored

- **Decision**: Secrets (database password, `BETTER_AUTH_SECRET`, public URL)
  go in `~/.config/containers/systemd/paperclip.env`, loaded by both Quadlet
  units via `EnvironmentFile=%h/.config/containers/systemd/paperclip.env`.
  This file is gitignored.
- **Rationale**: The upstream Quadlet files already use `EnvironmentFile=%h/...`
  pointing to this exact path. `BETTER_AUTH_SECRET` must be a strong random
  value (not the dev default `paperclip-dev-secret`). The constitution forbids
  secrets in git.
- **Secrets in `.env` (never committed)**:
  ```
  POSTGRES_USER=paperclip
  POSTGRES_PASSWORD=<strong-random-password>
  POSTGRES_DB=paperclip
  DATABASE_URL=postgres://paperclip:<password>@localhost:5432/paperclip
  BETTER_AUTH_SECRET=<64-char-random>
  PORT=3100
  SERVE_UI=true
  PAPERCLIP_PUBLIC_URL=http://console:3100
  PAPERCLIP_DEPLOYMENT_MODE=authenticated
  PAPERCLIP_DEPLOYMENT_EXPOSURE=private
  ```
- **Alternatives considered**: Hardcoding in Quadlet units — rejected (secrets
  would be in git). Using secrets management (Vault, etc.) — overkill for a
  personal fleet.

---

## Decision 5: `PAPERCLIP_PUBLIC_URL` — Tailscale Hostname

- **Decision**: Set `PAPERCLIP_PUBLIC_URL=http://console:3100`
- **Rationale**: Paperclip uses this URL to generate absolute links in emails,
  webhooks, and UI redirects. Using the Tailscale MagicDNS hostname `console`
  ensures links work from any machine on the fleet. Raw IPs would break if the
  machine's Tailscale IP changes; `localhost` would only work on `console` itself.
- **Alternatives considered**: `http://localhost:3100` — would break links
  from remote machines. Raw Tailscale IP — changes if Tailscale re-addresses.

---

## Decision 6: Data Persistence — Bind Mount + Named Volume

- **Decision**: Use a named Podman volume `paperclip-pgdata` for PostgreSQL
  data and a bind mount `~/.local/share/paperclip` for Paperclip application
  data (matching the upstream Quadlet `paperclip.container`)
- **Rationale**: The upstream unit uses `Volume=%h/.local/share/paperclip:/paperclip:Z`.
  Bind mounts to `~/.local/share/` are the conventional location for user data
  on Linux and are outside the repo. Named volumes for PostgreSQL follow the
  standard Podman pattern and survive container re-creation.
- **Alternatives considered**: Single named volume for everything — PostgreSQL
  and app data have different lifecycle needs; separating them is cleaner.

---

## Decision 7: `PAPERCLIP_DEPLOYMENT_MODE` and `PAPERCLIP_EXPOSURE`

- **Decision**: `authenticated` + `private`
- **Rationale**: `authenticated` requires sign-in to use Paperclip (no open
  anonymous access). `private` signals the service is not public-internet-facing.
  Both match the use case: private Tailscale fleet, individual accounts.
- **Alternatives considered**: `unauthenticated` — anyone on Tailscale could
  use the service without credentials; rejected for a production deployment.

---

## Source References

| Source | Used for |
|--------|----------|
| `paperclipai/paperclip` (GitHub) | Quadlet files, Dockerfile, docker-compose.yml, .env.example |
| Upstream `.env.example` | Environment variable names and defaults |
| Upstream `docker/quadlet/*.container` + `*.pod` | Unit file structure |
| Upstream `docker/docker-compose.yml` | Service architecture (two containers + volumes) |
| `docs/infra.md` (this repo) | Existing port assignments, service conventions |
