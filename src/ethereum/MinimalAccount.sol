// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IAccount} from "@account-abstraction/interfaces/IAccount.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "@account-abstraction/core/Helpers.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {console} from "forge-std/console.sol";

contract MinimalAccount is IAccount, Ownable {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error AA_NotFromEntryPoint();
    error AA_NotFromOwnerOrEntryPoint();
    error AA_ExecutionFailed(bytes result);

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    IEntryPoint public immutable i_entryPoint;

    constructor(address owner, address entryPoint) Ownable(owner) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert AA_NotFromEntryPoint();
        }
        _;
    }

    modifier onlyOwnerOrEntryPoint() {
        if (msg.sender != owner() && msg.sender != address(i_entryPoint)) {
            revert AA_NotFromOwnerOrEntryPoint();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNALS
    //////////////////////////////////////////////////////////////*/

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override onlyEntryPoint returns (uint256 validationData) {
        validationData = _validateSignature(userOp, userOpHash);
        if (validationData != SIG_VALIDATION_SUCCESS) return validationData;

        // Placeholder for other validation steps:
        // _validateNonce(userOp.nonce); // Important for replay protection
        _payPrefund(missingAccountFunds); // Logic to pay the EntryPoint if needed

        // If all checks pass up to this point, including signature.
        // For this lesson, we are only focusing on signature validation for the return.
        // In a complete implementation, if nonce and prefund also passed,
        // we'd still return the validationData which might be SIG_VALIDATION_SUCCESS
        // or a packed value if using timestamps.

        return validationData; // This will be SIG_VALIDATION_SUCCESS or SIG_VALIDATION_FAILED from _validateSignature
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata data
    ) external payable onlyOwnerOrEntryPoint {
        (bool success, bytes memory result) = dest.call{value: value}(data);
        if (!success) revert AA_ExecutionFailed(result);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNALS
    //////////////////////////////////////////////////////////////*/

    /**
     * Validate the signature of the user operation
     * @param userOp: The user operation to validate.
     * @param userOpHash: EIP-191 version of the signed hash
     */
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view returns (uint256) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            userOpHash
        );
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer == address(0) || signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }

        return SIG_VALIDATION_SUCCESS;
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success, ) = payable(msg.sender).call{
                value: missingAccountFunds
            }("");
            require(success, "Missing account funds");
        }
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
