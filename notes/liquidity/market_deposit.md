# Market deposit

### Create deposit

[`ExchangeRouter.createDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/router/ExchangeRouter.sol#L126-L135)

```
1. Send long and or short tokens to deposit vault
2. Send execution fee to deposit vault
3. Create deposit order

ExchangeRouter.createDeposit
└ DepositHandler.createDeposit
    └ DepositUtils.createDeposit
        ├ DepositVault.recordTransferIn
        ├ DepositVault.recordTransferIn
        └ DepositStoreUtils.set
```

### Execute deposit

[`DepositHandler.executeDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/exchange/DepositHandler.sol#L81-L109)

```
DepositHandler.executeDeposit
├ DepositStoreUtils.get
└ _executeDeposit
    └ ExecuteDepositUtils.executeDeposit
        ├ DepositStoreUtils.remove
        ├ MarketUtils.distributePositionImpactPool
        ├ PositionUtils.updateFundingAndBorrowingState
        ├ swap
        │   └ SwapUtils.swap
        ├ swap
        │   └ SwapUtils.swap
        ├ _executeDeposit
        │   ├ MarketUtils.applyDeltaToPoolAmount
        │   └ MarketToken.mint
        └ _executeDeposit
            ├ MarketUtils.applyDeltaToPoolAmount
            └ MarketToken.mint
```
