// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BLSSigCheckOperatorStateRetriever} from
    "lib/eigenlayer-middleware/src/unaudited/BLSSigCheckOperatorStateRetriever.sol";

contract DeployBLSSigCheckScript is Script {
    BLSSigCheckOperatorStateRetriever public blsSigCheck;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the BLSSigCheckOperatorStateRetriever
        blsSigCheck = new BLSSigCheckOperatorStateRetriever();
        console.log("BLSSigCheckOperatorStateRetriever deployed at:", address(blsSigCheck));

        vm.stopBroadcast();

        // Write deployment data
        _writeDeploymentJson(block.chainid);
    }

    function _writeDeploymentJson(uint256 chainId) internal {
        string memory outputPath = "script/deployments/bls-sig-check/";
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
            '    "blsSigCheck": "',
            vm.toString(address(blsSigCheck)),
            '"\n',
            "  }\n",
            "}"
        );
    }
}
