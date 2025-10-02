# Next Steps

## 1) Add an Engine Status page (quick win)
- Path: `web/app/engine-status/page.tsx` (included in this handoff pack).
- Visit `http://localhost:3000/engine-status` to see `{ status: "ok", ... }` when the daemon is up.

## 2) Simple UI (wireframes → scaffold)
- Drake will provide 2–3 flat mock images (1920×1080) for:
  1) Home/Discover (feed + search)
  2) Channel page (cover, list of videos, follow/host toggles)
  3) Watch page (player pane, title/desc/tags, related, comments placeholder)
- We’ll translate those mockups into a minimal set of pages/components using shadcn + Tailwind.
- Target: fast-loading shell with placeholders; no data wiring yet.

## 3) A11y cleanup in property panel
- Update form-field components to generate stable `id`s via `useId()` and set `htmlFor` on `<label>` accordingly.

## 4) First engine endpoint for library
- `POST /library/scan` that takes a base path (e.g., “My Uploads”) and returns file metadata (name, size, hash placeholder).
- Later: queue hashing and prep torrent metainfo on a background task.

## 5) CI hygiene (optional for now)
- Keep web job path-filtered; flip off `continue-on-error` once `npm run build` succeeds in CI.
- Add a `typecheck` script and run it in CI for web to catch TS breakages without full build.

## Branch plan
- Branch: `feat/ui-shell` (simple pages)
- Branch: `feat/engine-status` (page + tiny fetch util)
- Branch: `feat/engine-scan` (daemon route and web call)
