# Engine API

Base URL (dev): `http://127.0.0.1:5173`

## GET /health
Returns basic liveness.
```json
{ "status": "ok", "service": "video-engine", "version": "0.1.0" }
```

## POST /hash
Body:
```json
{ "path": "C:/absolute/path/to/file.mp4" }
```
Response:
```json
{ "sha256": "<hex>", "size": 123456 }
```

## GET /stream?path=<absolute>&range=handled-by-header
- Supports `Range: bytes=…` for seeking.
- Intended for local playback and future peer streaming.

> If any of these change, update this file and the context seed.
