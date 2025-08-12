// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20Errors} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {RebaseToken} from "contracts/RebaseToken.sol";
import {Vault} from "contracts/Vault.sol";

contract RebaseTokenTest is Test {
    RebaseToken public rebaseToken;
    Vault public vault;

    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public SEND_VALUE = 1e5;

    function setUp() public {
        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        vault = new Vault(address(rebaseToken));

        rebaseToken.grantRole(rebaseToken.MINT_AND_BURN_ROLE(), address(vault));
        vm.stopPrank();
    }

    function addRewardsToVault(uint256 amount) public {
        vm.deal(owner, amount);
        vm.prank(owner);
        (bool success, ) = payable(address(vault)).call{value: amount}("");
        if (!success) revert();
    }

    function testVaultDeposit(uint256 amount) public {
        // Min: 0.00001 ETH (1e5 wei),
        // Max: type(uint96).max to avoid overflows.
        amount = bound(amount, 1e5, type(uint96).max);

        // 1. Deposit ETH into the vault.
        vm.deal(alice, amount);
        vm.startPrank(alice);
        vault.deposit{value: amount}();

        // 2. Check initial rebase token balance for 'user'
        uint256 initialBalance = rebaseToken.balanceOf(alice);
        assertEq(initialBalance, amount);

        // 3. Warp time forward and check balance again
        uint256 timeDelta = 1 days;
        vm.warp(block.timestamp + timeDelta);
        uint256 balanceAfterFirstWarp = rebaseToken.balanceOf(alice);
        assertGt(balanceAfterFirstWarp, initialBalance);

        vm.warp(block.timestamp + timeDelta);
        uint256 balanceAfterSecondWarp = rebaseToken.balanceOf(alice);
        assertGt(balanceAfterSecondWarp, balanceAfterFirstWarp);

        vm.stopPrank();
    }

    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);

        // Deposit funds
        vm.startPrank(alice);
        vm.deal(alice, amount);
        vault.deposit{value: amount}();

        // Redeem funds
        vault.redeem(amount);

        uint256 balance = rebaseToken.balanceOf(alice);
        assertEq(balance, 0);
        vm.stopPrank();
    }

    function testRedeemAfterTimeHasPassed(
        uint256 depositAmount,
        uint256 time
    ) public {
        time = bound(time, 1000, type(uint96).max); // this is a crazy number of years - 2^96 seconds is a lot
        depositAmount = bound(depositAmount, 1e5, type(uint96).max); // this is an Ether value of max 2^78 which is crazy

        // Deposit funds
        vm.deal(alice, depositAmount);
        vm.prank(alice);
        vault.deposit{value: depositAmount}();

        // check the balance has increased after some time has passed
        vm.warp(time);
        uint256 balance = rebaseToken.balanceOf(alice);

        // Add rewards to the vault
        addRewardsToVault(balance - depositAmount);

        // Redeem funds
        vm.prank(alice);
        vault.redeem(balance);

        uint256 ethBalance = address(alice).balance;

        assertEq(balance, ethBalance);
        assertGt(balance, depositAmount);
    }

    function testTransfer(uint256 amount, uint256 amountToSend) public {
        amount = bound(amount, 1e5 + 1e3, type(uint96).max);
        amountToSend = bound(amountToSend, 1e5, amount - 1e3);

        hoax(alice, amount);
        vault.deposit{value: amount}();

        address userTwo = makeAddr("userTwo");
        uint256 userBalance = rebaseToken.balanceOf(alice);
        uint256 userTwoBalance = rebaseToken.balanceOf(userTwo);
        assertEq(userBalance, amount);
        assertEq(userTwoBalance, 0);

        // Update the interest rate so we can check the user interest rates are different after transferring.
        vm.prank(owner);
        rebaseToken.setInterestRate(4e10);

        // Send half the balance to another user
        vm.prank(alice);
        rebaseToken.transfer(userTwo, amountToSend);
        uint256 userBalanceAfterTransfer = rebaseToken.balanceOf(alice);
        uint256 userTwoBalanceAfterTransfer = rebaseToken.balanceOf(userTwo);
        assertEq(userBalanceAfterTransfer, userBalance - amountToSend);
        assertEq(userTwoBalanceAfterTransfer, userTwoBalance + amountToSend);

        // After some time has passed, check the balance of the two users has increased
        vm.warp(block.timestamp + 1 days);
        uint256 userBalanceAfterWarp = rebaseToken.balanceOf(alice);
        uint256 userTwoBalanceAfterWarp = rebaseToken.balanceOf(userTwo);
        // check their interest rates are as expected
        // since user two hadn't minted before, their interest rate should be the same as in the contract
        uint256 userTwoInterestRate = rebaseToken.getUserInterestRate(userTwo);
        assertEq(userTwoInterestRate, 5e10);
        // since user had minted before, their interest rate should be the previous interest rate
        uint256 userInterestRate = rebaseToken.getUserInterestRate(alice);
        assertEq(userInterestRate, 5e10);

        assertGt(userBalanceAfterWarp, userBalanceAfterTransfer);
        assertGt(userTwoBalanceAfterWarp, userTwoBalanceAfterTransfer);
    }

    function testGetPrincipleAmount() public {
        uint256 amount = 1e5;

        hoax(alice, amount);
        vault.deposit{value: amount}();
        uint256 principleAmount = rebaseToken.principalBalanceOf(alice);
        assertEq(principleAmount, amount);

        // check that the principle amount is the same after some time has passed
        vm.warp(block.timestamp + 1 days);
        uint256 principleAmountAfterWarp = rebaseToken.principalBalanceOf(
            alice
        );
        assertEq(principleAmountAfterWarp, amount);
    }

    /******************************************************************************************/
    /* test authorization functions                                                           */
    /******************************************************************************************/
    function testCannotSetInterestRate(uint256 newInterestRate) public {
        vm.startPrank(alice);
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        rebaseToken.setInterestRate(newInterestRate);
        vm.stopPrank();
    }

    function testCannotCallMint() public {
        vm.startPrank(alice);
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        rebaseToken.mint(alice, SEND_VALUE, rebaseToken.getInterestRate());
        vm.stopPrank();
    }

    function testCannotCallBurn() public {
        vm.startPrank(alice);
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        rebaseToken.burn(alice, SEND_VALUE);
        vm.stopPrank();
    }

    function testCannotWithdrawMoreThanBalance() public {
        vm.startPrank(alice);
        vm.deal(alice, SEND_VALUE);
        vault.deposit{value: SEND_VALUE}();
        vm.expectPartialRevert(IERC20Errors.ERC20InsufficientBalance.selector);
        vault.redeem(SEND_VALUE + 1);
        vm.stopPrank();
    }
}
