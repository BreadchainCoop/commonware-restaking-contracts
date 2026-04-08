// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";

import {IAvsServiceManager} from "../src/interfaces/IAvsServiceManager.sol";
import {Counter} from "../src/examples/Counter.sol";

contract CounterScript is Script {
    Counter public counter;

    function setUp() public {}

    function run() public {
        address registryCoordinator = vm.envAddress("REGISTRY_COORDINATOR_ADDRESS");
        address avsServiceManagerWrapper = vm.envAddress("AVS_SERVICE_MANAGER_WRAPPER_ADDRESS");

        vm.startBroadcast();

        counter = new Counter(
            ISlashingRegistryCoordinator(registryCoordinator), IAvsServiceManager(avsServiceManagerWrapper)
        );

        vm.stopBroadcast();

        // Write deployment data
        _writeDeploymentJson(block.chainid);
    }

    function _writeDeploymentJson(uint256 chainId) internal {
        string memory outputPath = "script/deployments/counter/";
        string memory fileName = string.concat(outputPath, vm.toString(chainId), ".json");

        // Create directory if it doesn't exist
        if (!vm.exists(outputPath)) {
            vm.createDir(outputPath, true);
        }

        // Create JSON string with deployment data
        string memory deploymentData = _generateDeploymentJson();

        vm.writeFile(fileName, deploymentData);
        console.log("Deployment artifacts written to:", fileName);
    }

    function _generateDeploymentJson() private view returns (string memory) {
        return string.concat(
            "{\n",
            '  "lastUpdate": {\n',
            '    "timestamp": "',
            vm.toString(block.timestamp),
            '",\n',
            '    "block_number": "',
            vm.toString(block.number),
            '"\n',
            "  },\n",
            '  "addresses": {\n',
            '    "counter": "',
            vm.toString(address(counter)),
            '"\n',
            "  }\n",
            "}"
        );
    }
}
