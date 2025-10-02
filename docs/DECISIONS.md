# Architecture Decision Records (brief)

## 2025-09-30 Use Axum + ReaderStream for /stream
Context: Need HTTP Range streaming quickly on Windows.
Decision: Axum 0.7 + tokio_util::io::ReaderStream.
Consequences: Simple and stable; multipart ranges can be added later.

## 2025-10-01 Hosting & CDN
Context: Need free SSL and DNS.
Decision: Use Cloudflare Free for DNS/SSL and proxy; Vercel can be added later for CI deploys.
Consequences: Zero-cost SSL; keep origin opaque; stay within Cloudflare ToS.
