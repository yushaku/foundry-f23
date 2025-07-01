// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {GundamNft} from "../src/GundamNft.sol";
import {console} from "forge-std/console.sol";

contract DeployGundamNft is Script {
    function run() external returns (GundamNft) {
        vm.startBroadcast();
        GundamNft gundamNft = new GundamNft();
        vm.stopBroadcast();

        return gundamNft;
    }
}
