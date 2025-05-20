// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";
contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        address registryCoordinator = vm.envAddress("REGISTRY_COORDINATOR_ADDRESS");
        counter = new Counter(ISlashingRegistryCoordinator(registryCoordinator));
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }
}
