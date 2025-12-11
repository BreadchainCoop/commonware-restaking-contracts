FROM rust:1.91-slim AS builder

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy workspace manifests and member manifests for dependency resolution
COPY Cargo.toml ./
COPY src/Cargo.toml ./src/Cargo.toml
COPY src/bindings/Cargo.toml ./src/bindings/Cargo.toml
COPY src/common/Cargo.toml ./src/common/Cargo.toml
COPY src/router/Cargo.toml ./src/router/Cargo.toml
COPY src/node/Cargo.toml ./src/node/Cargo.toml
COPY scripts/Cargo.toml ./scripts/Cargo.toml

# Create placeholder targets for workspace members so Cargo can resolve manifests
# Cargo.lock will be generated if it doesn't exist
RUN mkdir -p src/bindings/src src/common/src src/router/src src/node/src scripts \
    && echo 'pub fn _placeholder(){}' > src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/bindings/src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/common/src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/router/src/lib.rs \
    && echo 'pub fn _placeholder(){}' > src/node/src/app.rs \
    && echo 'pub fn _placeholder(){}' > scripts/verify_increments.rs \
    && cargo fetch

# Copy sources
COPY src ./src

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
