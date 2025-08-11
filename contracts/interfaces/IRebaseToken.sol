// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IRebaseToken {
    error RebaseToken__GrantRoleFailed();

    error RebaseToken__RevokeRoleFailed();

    error RebaseToken__InterestRateCanOnlyDecrease(
        uint256 oldInterestRate,
        uint256 newInterestRate
    );

    event InterestRateSet(uint256 newInterestRate);

    // /**
    //  * @notice  Interest Accrual: Before any transfer occurs, any pending interest for both the sender and the recipient must be calculated and effectively minted to their principal balances.
    //             This ensures that balances are up-to-date.
    //  * @dev Recipient's Interest Rate:
    //  -  New Recipient: If the recipient has a balance of zero before this transfer, they should inherit an interest rate.
    //     The chosen logic is for the recipient to inherit the sender's current user-specific interest rate (s_userInterestRate[_from]).
    //     This handles cases like user-to-user transfers or users consolidating funds into a new wallet they control.
    //  -  Existing Recipient: If the recipient already holds tokens (i.e., their balance is non-zero), their existing s_userInterestRate should not be altered by an incoming transfer.
    //     This prevents a potential attack where someone could send a tiny amount of tokens to another user to forcibly change (and potentially lower) their interest rate.
    // */
    // function transfer(address _to, uint256 _amount) external returns (bool);
    function mint(address _to, uint256 _amount, uint256 _interestRate) external;

    function burn(address _from, uint256 _amount) external;

    function getUserInterestRate(address _user) external view returns (uint256);

    function getInterestRate() external view returns (uint256);
}
