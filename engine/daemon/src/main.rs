use axum::{
    body::Body,
    extract::{DefaultBodyLimit, Query},
    http::{header, HeaderMap, HeaderValue, StatusCode},
    response::Response,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{fs::Metadata, io::SeekFrom, net::SocketAddr, path::PathBuf};
use tokio::{
    fs::File,
    io::{AsyncReadExt, AsyncSeekExt},
};
use tokio_util::io::ReaderStream;
use tower_http::{
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[derive(Serialize)]
struct Health {
    status: &'static str,
    service: &'static str,
    version: &'static str,
}

#[tokio::main]
async fn main() {
    // logging
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // allow the Next.js dev server to call this API
    let cors = CorsLayer::new()
        .allow_origin([
            "http://localhost:3000".parse().unwrap(),
            "http://127.0.0.1:3000".parse().unwrap(),
        ])
        .allow_methods(Any)
        .allow_headers(Any);

    let app = Router::new()
        .route("/health", get(health))
        .route("/hash", post(hash))
        .route("/stream", get(stream))
        .layer(TraceLayer::new_for_http())
        .layer(DefaultBodyLimit::max(1024 * 1024)) // 1MB JSON bodies is plenty here
        .layer(cors);

    let addr: SocketAddr = "127.0.0.1:5173".parse().unwrap();
    tracing::info!("daemon listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health() -> Json<Health> {
    Json(Health {
        status: "ok",
        service: "video-engine",
        version: "0.1.0",
    })
}

/* --------------------  /hash  -------------------- */

#[derive(Deserialize)]
struct HashReq {
    /// Full local file path, e.g. C:\Users\Drake\Videos\test.mp4
    path: String,
}

#[derive(Serialize)]
struct HashResp {
    sha256: String,
    size: u64,
}

async fn hash(Json(req): Json<HashReq>) -> Result<Json<HashResp>, (StatusCode, String)> {
    let mut file =
        File::open(&req.path)
            .await
            .map_err(|e| (StatusCode::BAD_REQUEST, format!("open: {e}")))?;
    let meta: Metadata =
        file.metadata()
            .await
            .map_err(|e| (StatusCode::BAD_REQUEST, format!("meta: {e}")))?;
    let size = meta.len();

    let mut hasher = Sha256::new();
    let mut buf = vec![0u8; 1024 * 1024]; // 1MB chunks
    loop {
        let n = file
            .read(&mut buf)
            .await
            .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("read: {e}")))?;
        if n == 0 {
            break;
        }
        hasher.update(&buf[..n]);
    }

    let sha = format!("{:x}", hasher.finalize());
    Ok(Json(HashResp { sha256: sha, size }))
}

/* --------------------  /stream  -------------------- */
/* Usage: GET /stream?path=C:\path\to\file.mp4
   With optional header: Range: bytes=START-END (single range supported)
*/

#[derive(Deserialize)]
struct StreamQuery {
    path: String,
}

async fn stream(
    Query(q): Query<StreamQuery>,
    headers: HeaderMap,
) -> Result<Response, (StatusCode, String)> {
    let mut file =
        File::open(&q.path)
            .await
            .map_err(|e| (StatusCode::BAD_REQUEST, format!("open: {e}")))?;
    let meta = file
        .metadata()
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, format!("meta: {e}")))?;
    let file_len = meta.len();

    // Parse "Range: bytes=start-end"
    let range_header = headers.get(header::RANGE).and_then(|h| h.to_str().ok());
    let (start, end, status) = if let Some(r) = range_header.and_then(|s| s.strip_prefix("bytes="))
    {
        let mut parts = r.split('-');
        let start = parts
            .next()
            .unwrap_or("0")
            .parse::<u64>()
            .unwrap_or(0);
        let end = parts
            .next()
            .and_then(|s| if s.is_empty() { None } else { Some(s) })
            .map(|s| s.parse::<u64>().unwrap_or(file_len.saturating_sub(1)))
            .unwrap_or(file_len.saturating_sub(1));
        (
            start.min(file_len.saturating_sub(1)),
            end.min(file_len.saturating_sub(1)),
            StatusCode::PARTIAL_CONTENT,
        )
    } else {
        (0, file_len.saturating_sub(1), StatusCode::OK)
    };

    // Seek and limit the readable window
    file.seek(SeekFrom::Start(start))
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("seek: {e}")))?;
    let to_read = end.saturating_sub(start).saturating_add(1);
    let limited = file.take(to_read);
    let stream = ReaderStream::new(limited);
    let body = Body::from_stream(stream);

    // Build response
    let mut resp = Response::new(body);
    *resp.status_mut() = status;

    let headers_mut = resp.headers_mut();
    headers_mut.insert(header::ACCEPT_RANGES, HeaderValue::from_static("bytes"));

    let content_type = mime_guess::from_path(PathBuf::from(&q.path)).first_or_octet_stream();
    headers_mut.insert(
        header::CONTENT_TYPE,
        HeaderValue::from_str(content_type.as_ref()).unwrap(),
    );

    if status == StatusCode::PARTIAL_CONTENT {
        headers_mut.insert(
            header::CONTENT_RANGE,
            HeaderValue::from_str(&format!("bytes {}-{}/{}", start, end, file_len)).unwrap(),
        );
        headers_mut.insert(
            header::CONTENT_LENGTH,
            HeaderValue::from_str(&to_read.to_string()).unwrap(),
        );
    } else {
        headers_mut.insert(
            header::CONTENT_LENGTH,
            HeaderValue::from_str(&file_len.to_string()).unwrap(),
        );
    }

    Ok(resp)
}
