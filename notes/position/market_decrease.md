# Market decrease

## Create order

```shell
ExchangeRouter.multicall
├ ExchangeRouter.sendWnt
├ ExchangeRouter.sendTokens
└ ExchangeRouter.createOrder
   └ OrderHandler.createOrder
      └ OrderUtils.createOrder
         ├ OrderVault.recordTransferIn
         └ OrderStoreUtils.set
```

## Execute order

```shell
OrderHandler.executeOrder
├─ OracleModule.withOraclePrices
│  └─ Oracle.setPrices
├─ OrderStoreUtils.get
├─ _executeOrder
│  └─ ExecuteOrderUtils.executeOrder
│     ├─ OrderStoreUtils.remove
│     ├─ MarketUtils.getMarketPrices
│     ├─ MarketUtils.distributePositionImpactPool
│     ├─ PositionUtils.updateFundingAndBorrowingState
│     ├─ processOrder
│     │  └─ DecreaseOrderUtils.processOrder
│     │     ├─ PositionStoreUtils.get
│     │     ├─ DecreasePositionUtils.decreasePosition
│     │     │  ├─ DecreasePositionCollateralUtils.processCollateral
│     │     │  │  ├─ PositionUtils.getPositionPnlUsd
│     │     │  │  ├─ MarketUtils.applyDeltaToPoolAmount
│     │     │  │  ├─ DecreasePositionSwapUtils.swapProfitToCollateralToken
│     │     │  │  ├─ PositionPricingUtils.getPositionFees
│     │     │  │  ├─ payForCost
│     │     │  │  ├─ payForCost
│     │     │  │  ├─ payForCost
│     │     │  │  ├─ payForCost
│     │     │  │  └─ payForCost
│     │     │  ├─ PositionUtils.updateTotalBorrowing
│     │     │  ├─ PositionStoreUtils.set or remove
│     │     │  ├─ MarketUtils.applyDeltaToCollateralSum
│     │     │  ├─ PositionUtils.updateOpenInterest
│     │     │  └─ DecreasePositionSwapUtils.swapWithdrawnCollateralToPnlToken
│     │     └─ SwapUtils.swap
│     └─ GasUtils.payExecutionFee
└─ OracleModule.withOraclePrices
   └─ Oracle.clearAllPrices
```
