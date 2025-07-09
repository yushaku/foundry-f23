// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {OracleLib, AggregatorV3Interface} from "./libraries/OracleLib.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DecentralizedStableCoin} from "./DSC.sol";
import {IDSCEngine} from "./interfaces/IDSCEngine.sol";

/**
 * @title DSCEngine
 * @author Yushaku
 * @notice This contract is based on the MakerDAO DSS system
 * @notice This contract is the core of the Decentralized Stablecoin system.
 * It handles all the logic for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized".
 * At no point, should the value of all collateral < the $ backed value of all the DSC.
 */
contract DSCEngine is IDSCEngine, ReentrancyGuard {
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) revert DSCEngine__NeedsMoreThanZero();
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;
    }
}
