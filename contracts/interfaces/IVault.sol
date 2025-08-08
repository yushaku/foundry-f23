// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IVault {
    error Vault__RedeemFailed();

    event Deposit(address indexed user, uint256 amount);

    event Redeem(address indexed user, uint256 amount);

    function deposit() external payable;

    function redeem(uint256 _amount) external;
}
