# Architecture (high-level)

**Goal:** YouTube-like UX in the foreground; self/fan-hosted distribution in the background.

- **Web UI (Next.js)**: browsing, following, channel pages, admin/studio.
- **Local Engine (Rust/Axum @ 127.0.0.1:5173)**: file hashing, scanning, eventual torrent/P2P, streaming via HTTP Range.
- **Folders on disk** (user-selected root):
  - `my_uploads/` – creator drops files here; UI publishes metadata.
  - `followed_channels/<channel>/` – auto-downloads.
  - `hosted_channels/<channel>/` – opt-in mirroring of favorites.
- **Future**: libtorrent integration, NAT traversal, encryption/ACLs, paid servers, sponsorship matching, ads injection in-app.

**Processes**
- `web/` — Next.js dev server (port 3000).
- `engine/daemon` — Axum HTTP daemon (port 5173).

**Contracts**
- Engine exposes small HTTP API (see `ENGINE_API.md`).
- Web calls engine from the browser (same machine) or through a bridge if packaged (Tauri later).
