// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStableCoin
 * @author Yushaku
 * Collateral: Exogenous
 * Minting (Stability Mechanism): Decentralized (Algorithmic)
 * Value (Relative Stability): Anchored (Pegged to USD)
 * Collateral Type: Crypto
 *
 * This is the contract meant to be owned by DSCEngine.
 * It is a ERC20 token that can be minted and burned by the DSCEngine smart contract.
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DSC__AmountMustBeMoreThanZero();
    error DSC__BurnAmountExceedsBalance();
    error DSC__NotZeroAddress();

    constructor(
        address _owner
    ) ERC20("DecentralizedStableCoin", "DSC") Ownable(_owner) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) revert DSC__AmountMustBeMoreThanZero();
        if (balance < _amount) revert DSC__BurnAmountExceedsBalance();

        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) revert DSC__NotZeroAddress();
        if (_amount <= 0) revert DSC__AmountMustBeMoreThanZero();

        _mint(_to, _amount);
        return true;
    }
}
