// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.i_owner(), address(msg.sender));
    }

    function testMinimumDollarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5 ether);
    }

    function testPriceFeedVersionIsSetCorrectly() external view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund{value: 1}();
    }

    function testFundUpdatesFundedDataStructure() external {
        vm.prank(alice); // the next transaction will be sent by alice
        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.getAddressToAmountFunded(alice), 1 ether);
    }

    function testAddsFunderToArrayOfFunders() external {
        vm.prank(alice);
        fundMe.fund{value: 1 ether}();

        vm.prank(bob);
        fundMe.fund{value: 2 ether}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);

        address funder2 = fundMe.getFunder(1);
        assertEq(funder2, bob);
    }

    modifier funded() {
        vm.prank(alice);
        fundMe.fund{value: 1 ether}();
        _;
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(bob);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() external funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() external {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax is a cheat code = prank and deal
            hoax(address(i), 1 ether);
            fundMe.fund{value: 1 ether}();
        }

        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, startingOwnerBalance + startingFundMeBalance);
    }
}
