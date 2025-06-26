# Market increase

## Create order

```shell
ExchangeRouter.multicall
├ ExchangeRouter.sendWnt
├ ExchangeRouter.sendTokens
└ ExchangeRouter.createOrder
   └ OrderHandler.createOrder
      └ OrderUtils.createOrder
         ├ OrderVault.recordTransferIn
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
│     │  └─ IncreaseOrderUtils.processOrder
│     │     ├─ SwapUtils.swap
│     │     ├─ PositionStoreUtils.get
│     │     └─ IncreasePositionUtils.increasePosition
│     │        ├─ processCollateral
│     │        │  ├─ PositionPricingUtils.getPositionFees
│     │        │  ├─ MarketUtils.applyDeltaToCollateralSum
│     │        │  └─ MarketUtils.applyDeltaToPoolAmount
│     │        ├─ MarketUtils.updateTotalBorrowing
│     │        ├─ PositionStoreUtils.set
│     │        └─ PositionUtils.updateOpenInterest
│     └─ GasUtils.payExecutionFee
└─ OracleModule.withOraclePrices
   └─ Oracle.clearAllPrices
```
