// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDSCEngine {
    /********************************************************************************************/
    /** Errors */
    /********************************************************************************************/
    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactorValue);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorNotImproved();

    /********************************************************************************************/
    /** Events */
    /********************************************************************************************/
    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );

    event CollateralRedeemed(
        address indexed redeemFrom,
        address indexed redeemTo,
        address token,
        uint256 amount
    );

    /********************************************************************************************/
    /** Functions */
    /********************************************************************************************/

    /**
     * @param collateral: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     * @param amountDscToMint: The amount of DSC you want to mint
     * @notice Deposit your collateral => mint DSC in one transaction
     */
    function depositCollateralAndMintDsc(
        address collateral,
        uint256 amountCollateral,
        uint256 amountDscToMint
    ) external;

    /**
     * @param collateral: The ERC20 token address of the collateral you're withdrawing
     * @param amountCollateral: The amount of collateral you're withdrawing
     * @param amountDscToBurn: The amount of DSC you want to burn
     * @notice burn DSC => withdraw collateral token in one transaction
     */
    function redeemCollateralForDsc(
        address collateral,
        uint256 amountCollateral,
        uint256 amountDscToBurn
    ) external;

    /**
     * @param collateral: The ERC20 token address of the collateral you're redeeming
     * @param amountCollateral: The amount of collateral you're redeeming
     * @notice redeem your collateral.
     * @notice If you have DSC minted, you will not be able to redeem until you burn your DSC
     */
    function redeemCollateral(
        address collateral,
        uint256 amountCollateral
    ) external;

    /**
     * @param amount: The amount of DSC you want to burn
     * @notice careful! You'll burn your DSC here! Make sure you want to do this...
     * @dev you might want to use this if you're nervous you might get liquidated and want to just burn
     * your DSC but keep your collateral in.
     */
    function burnDsc(uint256 amount) external;

    /**
     * @param collateral The ERC20 token address of the collateral you're using to make the protocol solvent again.
     * This is collateral that you're going to take from the user who is insolvent.
     * In return, you have to burn your DSC to pay off their debt, but you don't pay off your own.
     * @param user The user who is insolvent. They have to have a _healthFactor below MIN_HEALTH_FACTOR
     * @param debtToCover The amount of DSC you want to burn to cover the user's debt.
     *
     * You can partially liquidate a user.
     * You will get a 10% LIQUIDATION_BONUS for taking the users funds.
     * This function working assumes that the protocol will be roughly 150% overcollateralized in order for this to work.
     * A known bug would be if the protocol was only 100% collateralized, we wouldn't be able to liquidate anyone.
     * For example, if the price of the collateral plummeted before anyone could be liquidated.
     */
    function liquidate(
        address collateral,
        address user,
        uint256 debtToCover
    ) external;
}
