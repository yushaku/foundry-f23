# Market withdraw

### Create withdrawal

[`ExchangeRouter.createWithdrawal`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/router/ExchangeRouter.sol#L164-L173)

```
1. Send market token to withdrawal vault
2. Send execution fee to withdrawal vault
3. Create withdrawal order

ExchangeRouter.createWithdrawal
└ WithdrawalHandler.createWithdrawal
    └ WithdrawalUtils.createWithdrawal
        ├ WithdrawalVault.recordTransferIn
        ├ WithdrawalVault.recordTransferIn
        └ WithdrawalStoreUtils.set
```

### Execute withdrawal

[`WithdrawalHandler.executeWithdrawal`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/exchange/WithdrawalHandler.sol#L83-L115)

```
WithdrawalHandler.executeWithdrawal
├ WithdrawalStoreUtils.get
└ _executeWithdrawal
    └ ExecuteWithdrawalUtils.executeWithdrawal
        ├ WithdrawalStoreUtils.remove
        ├ MarketUtils.distributePositionImpactPool
        ├ PositionUtils.updateFundingAndBorrowingState
        └ _executeWithdrawal
            ├ _getOutputAmounts
            │   ├ MarketUtils.getPoolAmount
            │   └ MarketUtils.getPoolAmount
            ├ MarketUtils.applyDeltaToPoolAmount
            ├ MarketUtils.applyDeltaToPoolAmount
            ├ MarketToken.burn
            ├ _swap
            │   └ SwapUtils.swap
            └ _swap
                └ SwapUtils.swap
```
