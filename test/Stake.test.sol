// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./lib/TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import "../src/Constants.sol";
import {IRewardRouterV2} from "../src/interfaces/IRewardRouterV2.sol";
import {IRewardTracker} from "../src/interfaces/IRewardTracker.sol";
import {IGovToken} from "../src/interfaces/IGovToken.sol";
import {Stake} from "@exercises/Stake.sol";

contract StakeTest is Test {
    IERC20 constant gmx = IERC20(GMX);
    IGovToken constant gmxDao = IGovToken(GMX_DAO);
    IRewardRouterV2 constant rewardRouter = IRewardRouterV2(REWARD_ROUTER_V2);
    IRewardTracker constant rewardTracker = IRewardTracker(REWARD_TRACKER);

    TestHelper testHelper;
    Stake stake;

    function setUp() public {
        testHelper = new TestHelper();

        stake = new Stake();
        deal(GMX, address(this), 10 * 1e18);
        gmx.approve(address(stake), 10 * 1e18);
    }

    function testStake() public {
        // Stake
        stake.stake(10 * 1e18);
        assertEq(
            rewardTracker.stakedAmounts(address(stake)),
            10 * 1e18,
            "staked amount"
        );
        assertEq(
            stake.getStakedAmount(),
            rewardTracker.stakedAmounts(address(stake)),
            "get staked amount"
        );
        assertEq(gmxDao.balanceOf(address(stake)), 10 * 1e18, "GMX DAO");

        // Claim rewards
        testHelper.set(
            "GMX staked before", rewardTracker.stakedAmounts(address(stake))
        );

        vm.warp(block.timestamp + 1000);
        stake.claimRewards();

        testHelper.set(
            "GMX staked after", rewardTracker.stakedAmounts(address(stake))
        );

        console.log("GMX staked %e", testHelper.get("GMX staked after"));
        assertGt(
            testHelper.get("GMX staked after"),
            testHelper.get("GMX staked before"),
            "claim staked amount"
        );

        // Delegate
        stake.delegate(GMX_DAO_EXAMPLE_DELEGATEE);
        assertEq(
            gmxDao.delegates(address(stake)),
            GMX_DAO_EXAMPLE_DELEGATEE,
            "GMX DAO delegates"
        );

        // Unstake
        testHelper.set("GMX before", gmx.balanceOf(address(stake)));

        uint256 stakedAmount = rewardTracker.stakedAmounts(address(stake));
        stake.unstake(stakedAmount);

        testHelper.set("GMX after", gmx.balanceOf(address(stake)));

        console.log("GMX unstake %e", gmx.balanceOf(address(stake)));
        console.log(
            "Staked amount %e", rewardTracker.stakedAmounts(address(stake))
        );

        assertGt(
            testHelper.get("GMX after"), testHelper.get("GMX before"), "gmx"
        );
        assertEq(
            rewardTracker.stakedAmounts(address(stake)), 0, "staked amount"
        );
        assertEq(gmxDao.balanceOf(address(stake)), 0, "GMX DAO");
    }
}
