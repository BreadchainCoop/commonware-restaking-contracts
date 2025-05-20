// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";

contract CounterScript is Script {
    Counter public counter;

    function setUp() public {}

    function run() public {
        // Read registry coordinator address from environment variable
        address registryCoordinator = vm.envAddress("REGISTRY_COORDINATOR_ADDRESS");

        vm.startBroadcast();

        counter = new Counter(ISlashingRegistryCoordinator(registryCoordinator));

        vm.stopBroadcast();
    }
}
