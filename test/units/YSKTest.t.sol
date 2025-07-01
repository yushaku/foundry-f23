// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {DeployYSK} from "script/DeployYSK.s.sol";
import {YSK} from "src/YSK.sol";
import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract YSKTest is Test, ZkSyncChainChecker {
    uint256 BOB_STARTING_AMOUNT = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places

    YSK public ysk;
    DeployYSK public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeployYSK();
        if (!isZkSyncChain()) {
            ysk = deployer.run();
        } else {
            ysk = new YSK(INITIAL_SUPPLY);
            ysk.transfer(msg.sender, INITIAL_SUPPLY);
        }

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        vm.prank(msg.sender);
        ysk.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public view {
        assertEq(ysk.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ysk)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf

        vm.prank(bob);
        ysk.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        ysk.transferFrom(bob, alice, transferAmount);
        assertEq(ysk.balanceOf(alice), transferAmount);
        assertEq(ysk.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    // can you get the coverage up?
}
