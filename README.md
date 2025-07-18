# commonware-avs-counter

**commonware-avs-counter** is a boilerplate Actively Validated Service (AVS) smart contract for the Breadchain Cooperative AVS stack, designed to provide a simple, extensible example for building AVS integrations on top of EigenLayer.

---

## What is an AVS?

An Actively Validated Service (AVS) is a modular protocol or application that leverages EigenLayer restaking for decentralized security and coordination. AVSs allow developers to create new on-chain services—such as oracles, bridges, or custom logic—secured by a distributed set of actively validating nodes.

---

## What does commonware-avs-counter do?

This repository provides a minimal reference implementation of an AVS contract system, centered around a simple counter. The contract allows authorized AVS nodes to submit increment/decrement requests and demonstrate the following core AVS contract patterns:

- **Permissioned access** for AVS nodes/operators (integration with EigenLayer operator registry)
- **Simple state change** (incrementing/decrementing a counter value)
- **Event emission** for off-chain tracking and AVS node coordination
- **Upgradeable/extensible structure** for building more advanced AVS contracts

---

## Use Cases

- **Template** for building your own AVS smart contracts
- **Testing** the AVS stack (with the rest of the commonware AVS ecosystem)
- **Demonstration** of AVS node-to-contract interactions
- **Educational** tool for learning how to design AVS contracts in Solidity

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/)
- [Foundry](https://book.getfoundry.sh/) or [Hardhat](https://hardhat.org/) for contract development
- An Ethereum JSON-RPC endpoint (for deployment/testing)

### Installation

Clone the repo:
```sh
git clone https://github.com/BreadchainCoop/commonware-avs-counter.git
cd commonware-avs-counter
```

Install dependencies and build the contracts (using Foundry):
```sh
forge build
```

### Deployment

Deploy the contract using Foundry, Hardhat, or your preferred tool. Example with Foundry:
```sh
forge script script/Deploy.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
```

### Contract Overview

- `AvsCounter.sol`: The core contract, which maintains a simple integer counter and exposes functions to increment or decrement it. Only authorized AVS operators can call these functions.
- Includes event emission for off-chain AVS processes to listen and react.

---

## Extending this Boilerplate

This contract is intentionally minimal. To use as a base for your AVS:

- Integrate with your own operator registry or permissioning logic.
- Replace the counter logic with custom business logic and AVS functionality.
- Add additional events, access controls, or cross-contract integrations as needed.

---

## Related Repositories

- [commonware-avs-network-lookup](https://github.com/BreadchainCoop/commonware-avs-network-lookup): On-chain operator info aggregation and registry reader.
- [commonware-avs-router](https://github.com/BreadchainCoop/commonware-avs-router): HTTP API entrypoint for AVS orchestration.
- [commonware-avs-node](https://github.com/BreadchainCoop/commonware-avs-node): Contributor node software for AVS participation and signing.

---

## License

See [LICENSE](./LICENSE) for details.

---

Maintained by [Breadchain Cooperative](https://github.com/BreadchainCoop)
