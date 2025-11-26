# Build stage
FROM rust:1.91-slim AS builder

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy workspace manifests first for better caching
# Note: Build context is project root, so we copy from app/ directory
COPY app/Cargo.toml app/Cargo.lock ./
COPY app/src/Cargo.toml ./src/Cargo.toml
COPY app/src/bindings/Cargo.toml ./src/bindings/Cargo.toml
COPY app/src/router/Cargo.toml ./src/router/Cargo.toml
COPY app/src/node/Cargo.toml ./src/node/Cargo.toml

# Create placeholder targets for workspace members so Cargo can resolve manifests
RUN mkdir -p src/bindings/src src/router/src src/node/src \
    && echo 'pub fn _placeholder(){}' > src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/bindings/src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/router/src/lib.rs \
    && echo 'fn main(){}' > src/node/src/app.rs \
    && cargo fetch

# Copy sources
COPY app/src ./src

# Build only the node binary from the workspace
ARG BUILD_JOBS=2
RUN cargo build -p commonware-avs-node-app --release --jobs $BUILD_JOBS

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/commonware-avs-node-app /usr/local/bin/commonware-avs-node-app

ENTRYPOINT ["/usr/local/bin/commonware-avs-node-app"]
