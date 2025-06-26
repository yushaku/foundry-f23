// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {IDataStore} from "../interfaces/IDataStore.sol";
import {IReader} from "../interfaces/IReader.sol";
import {Order} from "../types/Order.sol";
import {Position} from "../types/Position.sol";
import {Market} from "../types/Market.sol";
import {MarketUtils} from "../types/MarketUtils.sol";
import {Price} from "../types/Price.sol";
import {IBaseOrderUtils} from "../types/IBaseOrderUtils.sol";
import {Oracle} from "../lib/Oracle.sol";
import "../Constants.sol";

contract Long {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IReader constant reader = IReader(READER);
    Oracle immutable oracle;

    constructor(address _oracle) {
        oracle = Oracle(_oracle);
    }

    // Task 1 - Receive execution fee refund from GMX
    receive() external payable {}

    // Task 2 - Create an order to long ETH with WETH collateral
    function createLongOrder(uint256 leverage, uint256 wethAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;
        weth.transferFrom(msg.sender, address(this), wethAmount);

        // Task 2.1 - Send execution fee to the order vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Task 2.2 - Send WETH to the order vault
        weth.approve(ROUTER, wethAmount);
        exchangeRouter.sendTokens({
            token: WETH,
            receiver: ORDER_VAULT,
            amount: wethAmount
        });

        // Task 2.3 - Create an order
        // 1 USD = 1e8
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);
        // 1 USD = 1e30
        // WETH = 18 decimal
        // ETH price = 8 decimals
        // 18 + 8 + 4 = 30
        uint256 sizeDeltaUsd = leverage * wethAmount * ethPrice * 1e4;
        // increase order:
        // - long: executionPrice should be smaller than acceptablePrice
        // - short: executionPrice should be larger than acceptablePrice
        uint256 acceptablePrice = ethPrice * 1e4 * 101 / 100;

        return exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_ETH_WETH_USDC,
                    initialCollateralToken: WETH,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketIncrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: true,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }

    // Task 3 - Get position key
    function getPositionKey() public view returns (bytes32 key) {
        return Position.getPositionKey({
            account: address(this),
            market: GM_TOKEN_ETH_WETH_USDC,
            collateralToken: WETH,
            isLong: true
        });
    }

    // Task 4 - Get position
    function getPosition(bytes32 key)
        public
        view
        returns (Position.Props memory)
    {
        return reader.getPosition(address(dataStore), key);
    }

    // Task 5 - Get position profit and loss
    function getPositionPnlUsd(bytes32 key, uint256 ethPrice)
        external
        view
        returns (int256)
    {
        Position.Props memory position = getPosition(key);

        MarketUtils.MarketPrices memory prices = MarketUtils.MarketPrices({
            indexTokenPrice: Price.Props({
                min: ethPrice * 1e30 / (1e8 * 1e18) * 99 / 100,
                max: ethPrice * 1e30 / (1e8 * 1e18) * 101 / 100
            }),
            longTokenPrice: Price.Props({
                min: ethPrice * 1e30 / (1e8 * 1e18) * 99 / 100,
                max: ethPrice * 1e30 / (1e8 * 1e18) * 101 / 100
            }),
            shortTokenPrice: Price.Props({
                min: 1 * 1e30 / 1e6 * 99 / 100,
                max: 1 * 1e30 / 1e6 * 101 / 100
            })
        });

        (int256 pnl, int256 uncappedPnl, uint256 sizeDeltaInTokens) = reader
            .getPositionPnlUsd({
            dataStore: address(dataStore),
            market: Market.Props({
                marketToken: GM_TOKEN_ETH_WETH_USDC,
                indexToken: WETH,
                longToken: WETH,
                shortToken: USDC
            }),
            prices: prices,
            positionKey: key,
            sizeDeltaUsd: position.numbers.sizeInUsd
        });

        return pnl;
    }

    // Task 6 - Create an order to close the long position created by this contract
    function createCloseOrder() external payable returns (bytes32 key) {
        uint256 executionFee = 0.1 * 1e18;

        // Task 6.1 - Get position
        Position.Props memory position = getPosition(getPositionKey());
        require(position.numbers.sizeInUsd > 0, "position size = 0");

        // Task 6.2 - Send execution fee to the order vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Task 6.3 - Create an order
        // decrease order:
        // - long: executionPrice should be larger than acceptablePrice
        // - short: executionPrice should be smaller than acceptablePrice
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);
        uint256 acceptablePrice = ethPrice * 1e4 * 99 / 100;

        return exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_ETH_WETH_USDC,
                    initialCollateralToken: WETH,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: position.numbers.sizeInUsd,
                    initialCollateralDeltaAmount: position.numbers.collateralAmount,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketDecrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: true,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }
}
