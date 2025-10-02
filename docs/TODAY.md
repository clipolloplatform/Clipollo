# Today (2025-10-01)

## What we did
- Pointed `clipollo.com` to Cloudflare; enabled proxy/SSL.
- Decided Cloudflare over Vercel Pro for cost right now.
- Installed shadcn/ui and added UI-Builder registry.
- Fixed `react-syntax-highlighter` import path to `dist/esm/styles/prism` and aligned version.
- Began normalizing `cn` imports to `@/lib/utils`.
- Investigated hydration mismatch from theme; solution staged (ThemeProvider + `suppressHydrationWarning`).

## In flight
- Search/replace lingering bad `cn` imports (esp. `components/ui/ui-builder/internal/*`).
- Update `app/layout.tsx` to use `ThemeProvider` and remove hard-coded dark class/style.
- Verify `/studio` renders fully after fixes.

## Next
- Commit repo to GitHub (private), push initial `/docs/*`.
- Add a small public “specs” repo with sanitized `/docs` for AI sessions (optional).
- Create `/docs/ENGINE_API.md` entries for next endpoints to stub:
  - `POST /library/scan` (root folders)
  - `GET /library/list`
  - `POST /torrent/create` (stub only)
- Add a simple `/settings` page to configure root folders (no real write yet).
