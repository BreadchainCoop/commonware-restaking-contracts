# Commonware AVS

Monorepo for the Commonware AVS reference implementation on EigenLayer. It contains:

- [`config`](./config): Configuration files for local network, contract deployments, and test keys
- [`scripts`](./scripts): Helper scripts for end-to-end validation and local integration testing
- [`src`](./srcr): Implementation of the example "counter" AVS usecase

## Example

[Counter](./src) demonstrates a simple end‑to‑end AVS flow:

- BLS quorum signing (n‑of‑m) by [`node`](./src/node) operators
- Aggregation and on‑chain execution by [`router`](./src/router) (increments a counter contract)

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Git

### Local Development

1. **Configure environment:**
```bash
cp example.env .env
```

For LOCAL mode (default), the example.env is pre-configured. You'll need to set a private key:
```bash
# Use Anvil's default test key for local development
echo "PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" >> .env
echo "FUNDED_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" >> .env
```

2. **Start all services:**
```bash
docker compose up -d
```

This will automatically build or pull the latest pre-built images (from ghcr.io) and start:
- Ethereum node (Anvil fork)
- EigenLayer contract deployment
- Signer service
- 3 operator nodes
- Router/orchestrator

3. **Monitor services:**
```bash
# View logs
docker compose logs -f router

# Check service status
docker compose ps
```

### Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (clean state)
docker compose down -v
```

## Licensing

This repository is dual-licensed under both the [Apache 2.0](./LICENSE-APACHE) and [MIT](./LICENSE-MIT) licenses. You may choose either license when employing this code.
