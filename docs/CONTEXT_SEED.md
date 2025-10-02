# Context Seed (Clipollo)

**Stack**: Next.js (TS, App Router) for UI; Rust Axum/Tokio engine at `http://127.0.0.1:5173`.  
**Run**: `run-all.bat` to start both; `stop-all.cmd` to stop.

**Engine API (current)**  
- `GET /health` → `{ status, service, version }`  
- `POST /hash { path }` → `{ sha256, size }`  
- `GET /stream?path=...` — Range seeking

**Key paths**  
- `engine/daemon/src/main.rs` — Axum routes  
- `web/app/studio/page.tsx` — UI Builder host page  
- `web/components/ui/ui-builder/*` — UI Builder components  
- `web/lib/utils.ts` — `cn()` helper (use this import: `import { cn } from "@/lib/utils"`)

**Rules for assistant**  
1. Return **full file replacements** with the exact path as a comment at top.  
2. Keep code compiling; update `/docs/ENGINE_API.md` if endpoints change.  
3. Prefer minimal dependencies; avoid snippet-only edits.

**Today’s objective**  
Finish fixing `cn` imports and theme hydration, get `/studio` to render cleanly. Then stub `POST /library/scan` in the engine and a simple UI button that calls it.
