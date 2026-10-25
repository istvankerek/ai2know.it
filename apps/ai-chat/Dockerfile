# AI Chat Service Dockerfile
FROM rust:1.77-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=build /app/target/release/ai-chat /usr/local/bin/ai-chat
EXPOSE 8081
CMD ["ai-chat"]
