// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {AvsServiceManagerWrapper} from "../src/AvsServiceManagerWrapper.sol";

// forge script script/DeployAvsServiceManagerWrapper.s.sol:DeployAvsServiceManagerWrapper \
//   --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
//
// Required env vars:
//   AVS_SERVICE_MANAGER      - address of the underlying ServiceManager to wrap
//
// Optional env vars (defaults to 2/3 majority, 300 block stale measure):
//   QUORUM_THRESHOLD         - numerator of the quorum threshold fraction (default: 2)
//   THRESHOLD_DENOMINATOR    - denominator of the quorum threshold fraction (default: 3)
//   BLOCK_STALE_MEASURE      - max age in blocks for a valid reference block (default: 300)

contract DeployAvsServiceManagerWrapper is Script {
    AvsServiceManagerWrapper public wrapper;

    function setUp() public {}

    function run() public {
        address serviceManager = vm.envAddress("AVS_SERVICE_MANAGER");
        uint256 quorumThreshold = vm.envOr("QUORUM_THRESHOLD", uint256(2));
        uint256 thresholdDenominator = vm.envOr("THRESHOLD_DENOMINATOR", uint256(3));
        uint256 blockStaleMeasure = vm.envOr("BLOCK_STALE_MEASURE", uint256(300));

        console.log("Deploying AvsServiceManagerWrapper...");
        console.log("Underlying ServiceManager:", serviceManager);
        console.log("QUORUM_THRESHOLD:         ", quorumThreshold);
        console.log("THRESHOLD_DENOMINATOR:    ", thresholdDenominator);
        console.log("BLOCK_STALE_MEASURE:      ", blockStaleMeasure);

        vm.startBroadcast();

        wrapper = new AvsServiceManagerWrapper(serviceManager, quorumThreshold, thresholdDenominator, blockStaleMeasure);

        vm.stopBroadcast();

        console.log("AvsServiceManagerWrapper deployed at:", address(wrapper));

        _writeDeploymentJson(block.chainid);
    }

    function _writeDeploymentJson(uint256 chainId) internal {
        string memory outputPath = "script/deployments/avs-service-manager-wrapper/";
        string memory fileName = string.concat(outputPath, vm.toString(chainId), ".json");

        if (!vm.exists(outputPath)) {
            vm.createDir(outputPath, true);
        }

        vm.writeFile(fileName, _generateDeploymentJson());
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
            '    "avsServiceManagerWrapper": "',
            vm.toString(address(wrapper)),
            '"\n',
            "  }\n",
            "}"
        );
    }
}
