// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IVault} from "./interfaces/IVault.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

// Core Requirements:
// 1. Store the address of the RebaseToken contract (passed in constructor).
// 2. Implement a deposit function:
//    - Accepts ETH from the user.
//    - Mints RebaseTokens to the user, equivalent to the ETH sent (1:1 peg initially).
// 3. Implement a redeem function:
//    - Burns the user's RebaseTokens.
//    - Sends the corresponding amount of ETH back to the user.
// 4. Implement a mechanism to add ETH rewards to the vault.

contract Vault is IVault {
    IRebaseToken public immutable i_rebaseToken;

    constructor(address _rebaseToken) {
        i_rebaseToken = IRebaseToken(_rebaseToken);
    }

    /**
     * @notice Receive ETH from the user.
     * @dev This function is used to receive ETH from the user.
     */
    receive() external payable {}

    /******************************************************************************************/
    /* external functions                                                                     */
    /******************************************************************************************/
    /**
     * @notice Deposit ETH into the vault.
     * @dev This function is used to deposit ETH into the vault.
     */
    function deposit() external payable {
        uint256 interestRate = i_rebaseToken.getInterestRate();
        i_rebaseToken.mint(msg.sender, msg.value, interestRate);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Redeem RebaseTokens for ETH.
     * @param _amount The amount of RebaseTokens to redeem.
     */
    function redeem(uint256 _amount) external {
        i_rebaseToken.burn(msg.sender, _amount);
        emit Redeem(msg.sender, _amount);

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
    }

    /******************************************************************************************/
    /* internal functions                                                                     */
    /******************************************************************************************/

    /******************************************************************************************/
    /* views functions                                                                        */
    /******************************************************************************************/
    function rebaseToken() external view returns (address) {
        return address(i_rebaseToken);
    }
}
