//! ai2know.it Backend – Rust/Axum
//! Belepesi pont

use axum::{routing::get, Router};
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
use tracing_subscriber;

#[tokio::main]
async fn main() {
    // Logging inicializalas
    tracing_subscriber::init();

    // Router felepites
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/api/v1/status", get(api_status))
        // TODO: modul route-ok hozzaadasa
        // .merge(modules::users::router())
        // .merge(modules::products::router())
        .layer(CorsLayer::permissive()); // TODO: CORS whitelist korlatozas

    // Szerver inditas
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::info!("Backend indul: {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health_check() -> &'static str {
    "OK"
}

async fn api_status() -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({
        "status": "running",
        "version": env!("CARGO_PKG_VERSION"),
    }))
}
