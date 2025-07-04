// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";

import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {SendPackedUserOp, PackedUserOperation} from "script/SendPackedUserOp.s.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {HelperConfig, NetworkConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";

contract MinimalAccountTest is Test {
  using MessageHashUtils for bytes32;

  HelperConfig helperConfig;
  MinimalAccount minimalAccount;
  ERC20Mock usdc;

  uint256 constant AMOUNT = 1 ether;
  address alice = makeAddr("alice");
  address owner;

  function setUp() public {
    DeployMinimal deployMinimal = new DeployMinimal();
    (helperConfig, minimalAccount) = deployMinimal.run();
    owner = helperConfig.getConfig().account;

    usdc = new ERC20Mock("USDC", "USDC");
    usdc.mint(alice, AMOUNT);
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
    PackedUserOperation memory userOp = SendPackedUserOp
      .generatedSignedUserOperation(executeCallData, config);

    bytes32 userOperationHash = IEntryPoint(config.entryPoint).getUserOpHash(
      userOp
    );

    // Act
    address actualSigner = ECDSA.recover(
      userOperationHash.toEthSignedMessageHash(),
      abi.decode(userOp.signature, (bytes))
    );

    // Assert
    assertEq(actualSigner, minimalAccount.owner());
  }
}
