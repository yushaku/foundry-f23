// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RewardDistribution} from "../src/RewardDistribution.sol";

contract RewardDistributionScript is Script {
    RewardDistribution public rewardDistribution;

    function setUp() public {}

    function run() public returns (address) {
        vm.startBroadcast();

        rewardDistribution = new RewardDistribution();

        vm.stopBroadcast();
        return address(rewardDistribution);
    }
}
