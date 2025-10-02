# Daily Summary — 2025-10-02

**Project:** Clipollo (community‑hosted video platform)  
**Focus today:** Stabilize Studio canvas (iframe adapter), fix CodeBlock + TipTap imports, tidy hydration warnings, and bring the repo + CI online.

## What we did
- **Studio iframe fix**
  - Added a lightweight `IframeAdapter` and refactored `AutoFrame` to stop passing non-DOM props (`frameRef`) to `<iframe>`.
  - Verified in DevTools that canvas iframes render **without** rogue props and with styles applied.

- **Code block rendering**
  - Implemented `components/ui/ui-builder/components/codeblock.tsx` with both **named** and **default** exports; switched to Prism `coldarkDark` ESM style path.
  - This unblocks `code-panel.tsx` / `markdown.tsx` imports that expect `{ CodeBlock }`.

- **TipTap alignment**
  - Installed **TipTap v2** packages using caret ranges (`@tiptap/*@^2`) with `--legacy-peer-deps` to avoid peer mismatches.
  - Goal: ensure `BubbleMenu` / `FloatingMenu` are available from `@tiptap/react` (v2 API).

- **Hydration & Grammarly noise**
  - Replaced `app/layout.tsx` to add `suppressHydrationWarning` and disable Grammarly overlays via `data-gramm*` attributes on `<html>`/`<body>`.

- **Git repo & CI**
  - Removed nested `.git` folders, initialized monorepo at `video-platform/`, committed and pushed to GitHub:
    - **Repo:** https://github.com/clipolloplatform/Clipollo
  - Adjusted GitHub Actions workflow so the **web** job can be non‑blocking and/or only runs when `web/**` changes.
  - Local line endings normalized on Windows (CRLF), repo stays clean.

## Current state
- **Web**: Next.js 15, React 19, Tailwind v4, shadcn/ui initialized, UI Builder installed.
- **Engine**: Rust daemon boots and exposes `/health` on `http://127.0.0.1:5173/health`.
- **CI**: Engine job passes; Web job gated/lenient while UI stabilizes.
- **Repo**: `main` is up to date; consider working on feature branches (`feat/ui-builder`).

## Known nits (safe to defer)
- A11y warnings for two `<label>` elements in the property panel (missing `htmlFor`→`id` wiring).
- Grammarly-related deprecation notices if the extension is enabled on `localhost`.
