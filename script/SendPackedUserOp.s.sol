// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {HelperConfig, NetworkConfig, ShareContract} from "./HelperConfig.s.sol";

contract SendPackedUserOp is Script, ShareContract {
  using MessageHashUtils for bytes32;

  function generatedSignedUserOperation(
    address account,
    bytes memory callData,
    NetworkConfig memory config,
    address abtractAccount
  ) public returns (PackedUserOperation memory) {
    uint256 nonce = vm.getNonce(abtractAccount);

    // step 1: generate the siigned data
    PackedUserOperation memory userOp = _generateUnsignedUserOperation(
      callData,
      abtractAccount,
      nonce - 1
    );

    // Step 2: Sign the UserOperation
    bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(userOp);

    bytes32 digest = userOpHash.toEthSignedMessageHash();

    // step 3: sign the digest
    uint8 v;
    bytes32 r;
    bytes32 s;
    if (block.chainid == LOCAL_CHAIN_ID) {
      (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
    } else {
      (v, r, s) = vm.sign(account, digest);
    }

    userOp.signature = abi.encodePacked(r, s, v);

    return userOp;
  }

  function _generateUnsignedUserOperation(
    bytes memory callData,
    address sender,
    uint256 nonce
  ) internal pure returns (PackedUserOperation memory) {
    // Example gas parameters (these may need tuning)
    uint128 verificationGasLimit = 16777216;
    uint128 callGasLimit = verificationGasLimit; // Often different in practice
    uint128 maxPriorityFeePerGas = 256;
    uint128 maxFeePerGas = maxPriorityFeePerGas; // Simplification for example

    // Pack accountGasLimits: (verificationGasLimit << 128) | callGasLimit
    bytes32 accountGasLimits = bytes32(
      (uint256(verificationGasLimit) << 128) | uint256(callGasLimit)
    );

    // Pack gasFees: (maxFeePerGas << 128) | maxPriorityFeePerGas
    bytes32 gasFees = bytes32(
      (uint256(maxFeePerGas) << 128) | uint256(maxPriorityFeePerGas)
    );

    return
      PackedUserOperation({
        sender: sender,
        nonce: nonce,
        initCode: hex"", // Empty for existing accounts
        callData: callData,
        accountGasLimits: accountGasLimits,
        preVerificationGas: verificationGasLimit, // Often related to verificationGasLimit
        gasFees: gasFees,
        paymasterAndData: hex"", // Empty if not using a paymaster
        signature: hex"" // Crucially, the signature is blank for an unsigned operation
      });
  }
}
