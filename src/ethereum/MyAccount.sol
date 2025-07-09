// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {Account} from "@openzeppelin/community-contracts/account/Account.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC7821} from "@openzeppelin/community-contracts/account/extensions/ERC7821.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {MultiSignerERC7913} from "@openzeppelin/community-contracts/utils/cryptography/signers/MultiSignerERC7913.sol";

/// @custom:oz-upgrades-unsafe-allow constructor
contract MyAccount is
  Initializable,
  Account,
  IERC1271,
  MultiSignerERC7913,
  ERC7821,
  ERC721Holder,
  ERC1155Holder
{
  constructor() {
    _disableInitializers();
  }

  function isValidSignature(
    bytes32 hash,
    bytes calldata signature
  ) public view override returns (bytes4) {
    return
      _rawSignatureValidation(hash, signature)
        ? IERC1271.isValidSignature.selector
        : bytes4(0xffffffff);
  }

  function initializeMultisig(
    bytes[] memory signers,
    uint256 threshold
  ) public initializer {
    _addSigners(signers);
    _setThreshold(threshold);
  }

  function addSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
    _addSigners(signers);
  }

  function removeSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
    _removeSigners(signers);
  }

  function setThreshold(uint256 threshold) public onlyEntryPointOrSelf {
    _setThreshold(threshold);
  }

  function _erc7821AuthorizedExecutor(
    address caller,
    bytes32 mode,
    bytes calldata executionData
  ) internal view override returns (bool) {
    return
      caller == address(entryPoint()) ||
      super._erc7821AuthorizedExecutor(caller, mode, executionData);
  }
}

