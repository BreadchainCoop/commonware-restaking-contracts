# Commonware AVS Counter

This repository contains both a Foundry project (Solidity contracts) and a Rust project.

## Repository Structure

```
.
├── contracts/          # Foundry project (Solidity contracts)
│   ├── src/           # Solidity source files
│   ├── script/        # Deployment scripts
│   ├── test/          # Test files
│   ├── lib/           # Dependencies
│   └── foundry.toml   # Foundry configuration
└── counter/           # Rust project (AVS implementation)
    ├── src/           # Rust source files
    ├── Cargo.toml     # Rust dependencies
    └── rust-toolchain.toml  # Rust toolchain configuration
```

## Foundry Project

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

### Documentation

https://book.getfoundry.sh/

### Usage

All Foundry commands should be run from the `contracts/` directory:

#### Build

```shell
$ cd contracts
$ forge build
```

#### Test

```shell
$ cd contracts
$ forge test
```

#### Format

```shell
$ cd contracts
$ forge fmt
```

#### Gas Snapshots

```shell
$ cd contracts
$ forge snapshot
```

#### Anvil

```shell
$ cd contracts
$ anvil
```

#### Environment Setup

Copy the example environment file and update it with your values:
```shell 
cd contracts
cp example.env .env
```

#### Deploy

##### Deploy BLSSigCheckOperatorStateRetriever

To deploy the BLSSigCheckOperatorStateRetriever contract:

```shell
$ cd contracts
$ forge script script/DeployBLSSigCheck.s.sol:DeployBLSSigCheckScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

This will deploy the BLSSigCheckOperatorStateRetriever contract and output its deployed address.

##### Environment Variables

Before deploying, make sure to set the `REGISTRY_COORDINATOR_ADDRESS` environment variable in your `.env` file.

##### Deploy Counter

To deploy the Counter contract:

```shell
$ cd contracts
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

#### Cast

```shell
$ cd contracts
$ cast <subcommand>
```

#### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Rust Project

The `counter/` directory contains a Rust project that implements the Counter AVS using the [commonware-restaking](https://github.com/BreadchainCoop/commonware-restaking) library.

### Dependencies

The project imports the following crates from `commonware-restaking`:
- `commonware-avs-core`: Core protocol types, validators, and wire formats
- `commonware-avs-bindings`: On-chain contract bindings

### Usage

#### Build

```shell
$ cd counter
$ cargo build
```

#### Run

```shell
$ cd counter
$ cargo run
```

#### Check (without building)

```shell
$ cd counter
$ cargo check
```

#### Test

```shell
$ cd counter
$ cargo test
```

### Development

The project uses Rust edition 2024 and includes:
- Tracing support for logging
- Async runtime with Tokio
- Error handling with `anyhow`

You can extend the `main.rs` file to implement your Counter AVS logic using the types and utilities from `commonware-avs-core` and `commonware-avs-bindings`.