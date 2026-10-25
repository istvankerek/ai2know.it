# Backend Dockerfile – Rust/Axum
# Multi-stage: dev + prod

# --- DEV ---
FROM rust:1.77-slim AS dev
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev
COPY Cargo.toml Cargo.lock* ./
COPY src ./src
RUN cargo build
EXPOSE 8080
CMD ["cargo", "run"]

# --- BUILD ---
FROM rust:1.77-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev
COPY . .
RUN cargo build --release

# --- PROD ---
FROM debian:bookworm-slim AS prod
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=build /app/target/release/backend /usr/local/bin/backend
EXPOSE 8080
CMD ["backend"]
