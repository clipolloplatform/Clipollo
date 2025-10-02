# Context Seed (Snapshot)

**Product idea:** Clipollo — a self/fan‑hosted video platform (P2P-assisted, BitTorrent/libtorrent planned) with a YouTube‑like UX, auto‑download for followed channels, optional community hosting, and future sponsor matching & package buys.

**Tech shape (current)**
- **Web**: Next.js 15 (App Router), React 19, Tailwind v4, shadcn/ui, “UI Builder” registry.
- **Desktop/mobile (future)**: Tauri for desktop; React Native (later) for mobile. Heavy networking planned in a Rust core.
- **Engine**: Rust daemon (Axum/Tokio) running locally at `http://127.0.0.1:5173` (health route working).
- **Video tooling**: FFmpeg installed locally for future ingestion/transcode pipelines.

**Repo & tooling**
- **Monorepo**: `engine/` (Rust) + `web/` (Next.js) + `docs/`.
- **Scripts**: `run-all.bat` (launch daemon + web), `stop-all.cmd` (shut down both).
- **CI**: GitHub Actions; jobs per folder; web job currently allowed to fail/skip while UI stabilizes.
- **Package constraints**: TipTap **v2** across all editor packages; `react-syntax-highlighter@15` with ESM styles.

**Recent fixes**
- Replaced raw `<iframe>` usage with an `IframeAdapter` (prevents invalid DOM props).
- Implemented a local `CodeBlock` with both named + default exports.
- Quieted hydration/extension warnings by amending `app/layout.tsx` with `suppressHydrationWarning` and `data-gramm*` flags.

**Open items (near-term)**
- Wire `label` → `input` `id` pairs in UI Builder form fields to clear A11y warnings.
- Add `/engine-status` page to ping daemon’s `/health` and show JSON.
- Begin **simple UI** milestone: landing/home feed, channel page, watch page.
- Define folder watcher + API surface for “My Uploads” directory (daemon route: `POST /library/scan`).

**Conventions**
- Work on feature branches, PR into `main`.
- Commit lockfiles: `web/package-lock.json`, `engine/**/Cargo.lock`.
- Keep Next.js/React versions consistent with the UI builder registry; TipTap stays on v2 for now.

**Source Logs**
- See [Full Chat Index](FULL_CHAT_INDEX.md) (all complete chat transcripts are listed there).

