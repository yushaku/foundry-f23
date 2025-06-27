// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RewardDistribution.sol";
import "script/RewardDistribution.s.sol";

contract RewardDistributionTest is Test {
    RewardDistributionScript public rewardDistributionScript;
    address public rewardDistributionAddress;

    function setUp() public {
        rewardDistributionScript = new RewardDistributionScript();
        rewardDistributionAddress = rewardDistributionScript.run();
    }
}
