FROM rust:1.91-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy workspace manifests and member manifests for dependency resolution
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

# Copy sources needed to build the router package
COPY app/src ./src

# Build only the router binary from the workspace
ARG BUILD_JOBS=2
RUN cargo build -p commonware-avs-router-app --release --jobs $BUILD_JOBS

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1000 -s /bin/bash appuser

# Copy the binary from builder
COPY --from=builder /app/target/release/commonware-avs-router-app /usr/local/bin/commonware-avs-router-app

# Copy configuration files
COPY config /app/config

# Set ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Expose port 3000 for the application
EXPOSE 3000

# Run the binary
ENTRYPOINT ["commonware-avs-router-app"]
