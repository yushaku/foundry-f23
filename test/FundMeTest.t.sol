// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.i_owner(), address(msg.sender));
    }

    function testMinimumDollarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5 ether);
    }

    function testPriceFeedVersionIsSetCorrectly() external view{
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
    }
}