// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {BLSSigCheckOperatorStateRetriever} from "lib/eigenlayer-middleware/src/unaudited/BLSSigCheckOperatorStateRetriever.sol";
import {BLSSignatureChecker} from "lib/eigenlayer-middleware/src/BLSSignatureChecker.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";
contract Counter is BLSSigCheckOperatorStateRetriever, BLSSignatureChecker {
    uint256 public number;

    constructor(
        ISlashingRegistryCoordinator _registryCoordinator
    ) BLSSignatureChecker(_registryCoordinator) {}

    function increment() public {
        number++;
    }
}
