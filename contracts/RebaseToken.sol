// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

/**
 * @title RebaseToken
 * @author Yushaku
 * @notice This is a cross-chain rebase token that incentivises users to deposit into a vault and gain interest in rewards.
 * @notice The interest rate in the smart contract can only decrease.
 * @notice Each user will have their own interest rate that is the global interest rate at the time of deposit.
 */
contract RebaseToken is IRebaseToken, ERC20, AccessControl, Ownable {
    uint256 private constant PRECISION_FACTOR = 1e18;
    bytes32 public constant MINT_AND_BURN_ROLE =
        keccak256("MINT_AND_BURN_ROLE");

    uint256 private s_interestRate = 5e10; // 0.000005% per second
    mapping(address user => uint256 interestRate) private s_userInterestRate; // The interest rate per second
    mapping(address user => uint256 timestamp)
        private s_userLastUpdatedTimestamp;

    constructor() ERC20("Rebase Token", "RBT") Ownable(msg.sender) {
        bool success = _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        if (!success) revert RebaseToken__GrantRoleFailed();
    }

    /******************************************************************************************/
    /* external functions                                                                     */
    /******************************************************************************************/

    /**
     * @notice Only the admin can grant a role to an account.
     * @param _role The role to grant.
     * @param _account The account to grant the role to.
     */
    function grantRole(
        bytes32 _role,
        address _account
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        bool success = _grantRole(_role, _account);
        if (!success) revert RebaseToken__GrantRoleFailed();
    }

    /**
     * @notice Only the admin can revoke a role from an account.
     * @param _role The role to revoke.
     * @param _account The account to revoke the role from.
     */
    function revokeRole(
        bytes32 _role,
        address _account
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        bool success = _revokeRole(_role, _account);
        if (!success) revert RebaseToken__RevokeRoleFailed();
    }

    /**
     * @notice Set the global interest rate for the contract.
     * @param _newInterestRate The new interest rate to set (scaled by PRECISION_FACTOR basis points per second).
     * @dev Access control (e.g., onlyOwner) should be added.
     */
    function setInterestRate(
        uint256 _newInterestRate
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    /**
     * @notice Mints tokens to a user, typically upon deposit.
     * @dev Also mints accrued interest and locks in the current global rate for the user.
     * @param _to The address to mint tokens to.
     * @param _amount The principal amount of tokens to mint.
     */
    function mint(
        address _to,
        uint256 _amount,
        uint256 _interestRate
    ) external onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = _interestRate;
        _mint(_to, _amount);
    }

    /**
     * @notice Burns tokens when user withdraws from vault.
     * @param _from The address to burn tokens from.
     * @param _amount The amount of tokens to burn.
     */
    function burn(
        address _from,
        uint256 _amount
    ) external onlyRole(MINT_AND_BURN_ROLE) {
        // If the user wants to burn all their tokens, set _amount to max uint256.
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_from);
        }

        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    /**
     * @notice Transfers tokens from the caller to a recipient.
     * Accrued interest for both sender and recipient is minted before the transfer.
     * If the recipient is new, they inherit the sender's interest rate.
     * @param _recipient The address to transfer tokens to.
     * @param _amount The amount of tokens to transfer. Can be type(uint256).max to transfer full balance.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transfer(
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);

        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }

        // Ensure _amount > 0 to avoid setting rate on 0-value initial transfer
        if (balanceOf(_recipient) == 0 && _amount > 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[msg.sender];
        }

        return super.transfer(_recipient, _amount);
    }

    /**
     * @notice Transfers tokens from one address to another, on behalf of the sender,
     * provided an allowance is in place.
     * Accrued interest for both sender and recipient is minted before the transfer.
     * If the recipient is new, they inherit the sender's interest rate.
     * @param _sender The address to transfer tokens from.
     * @param _recipient The address to transfer tokens to.
     * @param _amount The amount of tokens to transfer. Can be type(uint256).max to transfer full balance.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);

        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }

        // Set recipient's interest rate if they are new
        if (balanceOf(_recipient) == 0 && _amount > 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[_sender];
        }

        return super.transferFrom(_sender, _recipient, _amount);
    }

    /******************************************************************************************/
    /* internal functions                                                                     */
    /******************************************************************************************/

    /**
     * @dev Internal function to calculate and mint accrued interest for a user.
     * @dev Updates the user's last updated timestamp.
     * @param _user The address of the user.
     */
    function _mintAccruedInterest(address _user) internal {
        uint256 previousBalance = super.balanceOf(_user);
        uint256 currentBalance = balanceOf(_user);
        uint256 interest = currentBalance - previousBalance;

        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        _mint(_user, interest);
    }

    /**
     * @dev Calculates the growth factor due to accumulated interest since the user's last update.
     * @param _user The address of the user.
     * @return linearInterestFactor The growth factor, scaled by PRECISION_FACTOR. (e.g., 1.05x growth is 1.05 * 1e18).
     */
    function _calculateUserAccumulatedInterest(
        address _user
    ) internal view returns (uint256) {
        uint256 time = block.timestamp - s_userLastUpdatedTimestamp[_user];
        // represents the linear growth over time = (interest rate * time) + 1
        return (s_userInterestRate[_user] * time) + PRECISION_FACTOR;
    }

    /******************************************************************************************/
    /* views functions                                                                        */
    /******************************************************************************************/

    /**
     * @notice Gets the locked-in interest rate for a specific user.
     * @param _user The address of the user.
     * @return The user's specific interest rate.
     */
    function getUserInterestRate(
        address _user
    ) external view returns (uint256) {
        return s_userInterestRate[_user];
    }

    /**
     * @notice Returns the current balance of an account, including accrued interest.
     * @param _user The address of the account.
     * @return The total balance including interest.
     */
    function balanceOf(address _user) public view override returns (uint256) {
        uint256 principalBalance = super.balanceOf(_user);
        if (principalBalance == 0) return 0;

        uint256 growthFactor = _calculateUserAccumulatedInterest(_user);
        return (principalBalance * growthFactor) / PRECISION_FACTOR;
    }

    /**
     * @notice Gets the principle balance of a user (tokens actually minted to them), excluding any accrued interest.
     * @param _user The address of the user.
     * @return The principle balance of the user.
     */
    function principalBalanceOf(address _user) external view returns (uint256) {
        return super.balanceOf(_user); // Calls ERC20.balanceOf, which returns _balances[_user]
    }

    /**
     * @notice Gets the current global interest rate for the token.
     * @return The current global interest rate.
     */
    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }
}
