# Clipollo – Video Platform (Monorepo)

**UI**: Next.js (TypeScript, App Router) — dev at http://localhost:3000  
**Engine**: Rust (Axum/Tokio) — dev at http://127.0.0.1:5173

## Quick start

On Windows:
```bat
run-all.bat    # starts engine + web (two terminals)
stop-all.cmd   # stops both
```

Docs live in `/docs`. The short context seed for new AI sessions is in `/docs/CONTEXT_SEED.md`.

---

### Conventions
- Return *full-file replacements* in PRs (no fragments).
- Use Conventional Commits: `feat(web): …`, `fix(engine): …`, `docs: …`.
- Keep sample media tiny; never commit secrets.
