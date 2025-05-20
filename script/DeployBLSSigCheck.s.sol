// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BLSSigCheckOperatorStateRetriever} from "lib/eigenlayer-middleware/src/unaudited/BLSSigCheckOperatorStateRetriever.sol";

contract DeployBLSSigCheckScript is Script {
    BLSSigCheckOperatorStateRetriever public blsSigCheck;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the BLSSigCheckOperatorStateRetriever
        blsSigCheck = new BLSSigCheckOperatorStateRetriever();
        console.log("BLSSigCheckOperatorStateRetriever deployed at:", address(blsSigCheck));

        vm.stopBroadcast();
    }
} 