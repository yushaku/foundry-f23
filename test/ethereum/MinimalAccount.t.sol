// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "@account-abstraction/core/Helpers.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";

import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {SendPackedUserOp, PackedUserOperation} from "script/SendPackedUserOp.s.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {HelperConfig, NetworkConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";

contract MinimalAccountTest is Test {
  using MessageHashUtils for bytes32;

  MinimalAccount minimalAccount;
  HelperConfig helperConfig;
  ERC20Mock usdc;

  uint256 constant AMOUNT = 1 ether;
  address owner;
  address alice = makeAddr("alice");

  function setUp() public {
    DeployMinimal deployMinimal = new DeployMinimal();
    (helperConfig, minimalAccount) = deployMinimal.run();

    owner = minimalAccount.owner();
    usdc = new ERC20Mock("USDC", "USDC");
  }

  function testOwnerCanExecuteCommand() public {
    // arrange
    assertEq(usdc.balanceOf(address(minimalAccount)), 0);

    vm.startPrank(owner);
    address dest = address(usdc);
    uint256 value = 0;
    bytes memory functionData = abi.encodeWithSelector(
      ERC20Mock.mint.selector,
      minimalAccount,
      AMOUNT
    );

    // act
    minimalAccount.execute(dest, value, functionData);
    vm.stopPrank();

    // assert
    assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
  }

  function test_nonOwnerCannotExecuteCommand() public {
    vm.startPrank(alice);
    address dest = address(usdc);
    uint256 value = 0;
    bytes memory functionData = abi.encodeWithSelector(
      ERC20Mock.mint.selector,
      minimalAccount,
      AMOUNT
    );

    // act
    vm.expectRevert(MinimalAccount.AA_NotFromOwnerOrEntryPoint.selector);
    minimalAccount.execute(dest, value, functionData);
    vm.stopPrank();

    // assert
    assertEq(usdc.balanceOf(address(minimalAccount)), 0);
  }

  function test_recoverSignOp() public {
    SendPackedUserOp sendPackedUserOp = new SendPackedUserOp();
    // Arrange
    assertEq(usdc.balanceOf(address(minimalAccount)), 0);

    address dest = address(usdc);
    uint256 value = 0;
    bytes memory functionData = abi.encodeWithSelector(
      ERC20Mock.mint.selector,
      address(minimalAccount),
      AMOUNT
    );

    bytes memory executeCallData = abi.encodeWithSelector(
      MinimalAccount.execute.selector,
      dest,
      value,
      functionData
    );

    NetworkConfig memory config = helperConfig.getConfig();
    PackedUserOperation memory userOp = sendPackedUserOp
      .generatedSignedUserOperation(
        owner,
        executeCallData,
        config,
        address(minimalAccount)
      );

    bytes32 userOperationHash = IEntryPoint(config.entryPoint).getUserOpHash(
      userOp
    );

    // Act
    address actualSigner = ECDSA.recover(
      userOperationHash.toEthSignedMessageHash(),
      userOp.signature
    );

    // Assert
    assertEq(actualSigner, owner);
  }

  function test_validateUserOp() public {
    // Arrange
    address dest = address(usdc);
    uint256 value = 0;
    bytes memory functionData = abi.encodeWithSelector(
      ERC20Mock.mint.selector,
      address(minimalAccount),
      AMOUNT
    );

    bytes memory executeCallData = abi.encodeWithSelector(
      MinimalAccount.execute.selector,
      dest,
      value,
      functionData,
      minimalAccount
    );

    NetworkConfig memory config = helperConfig.getConfig();
    SendPackedUserOp sendPackedUserOp = new SendPackedUserOp();
    PackedUserOperation memory userOp = sendPackedUserOp
      .generatedSignedUserOperation(
        owner,
        executeCallData,
        config,
        address(minimalAccount)
      );

    bytes32 userOperationHash = IEntryPoint(config.entryPoint).getUserOpHash(
      userOp
    );

    uint missingAccountFunds = 0;

    // Act
    vm.prank(address(config.entryPoint));
    uint256 validationData = minimalAccount.validateUserOp(
      userOp,
      userOperationHash,
      missingAccountFunds
    );

    // Assert
    assertEq(validationData, SIG_VALIDATION_SUCCESS);
  }

  function test_entryPointCanExecute() public {
    address dest = address(usdc);
    uint256 value = 0;
    bytes memory functionData = abi.encodeWithSelector(
      ERC20Mock.mint.selector,
      address(minimalAccount),
      AMOUNT
    );

    bytes memory executeCallData = abi.encodeWithSelector(
      MinimalAccount.execute.selector,
      dest,
      value,
      functionData,
      address(minimalAccount)
    );

    NetworkConfig memory config = helperConfig.getConfig();
    SendPackedUserOp sendPackedUserOp = new SendPackedUserOp();
    PackedUserOperation memory userOp = sendPackedUserOp
      .generatedSignedUserOperation(
        owner,
        executeCallData,
        config,
        address(minimalAccount)
      );

    // fund
    vm.deal(address(alice), AMOUNT);

    // act
    PackedUserOperation[] memory ops = new PackedUserOperation[](1);
    ops[0] = userOp;

    // Act
    vm.startPrank(alice);
    // vm.breakpoint("a");
    IEntryPoint(config.entryPoint).depositTo{value: AMOUNT}(
      address(minimalAccount)
    );

    IEntryPoint(config.entryPoint).handleOps(ops, payable(alice));
    vm.stopPrank();

    // Assert
    assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
  }
}
