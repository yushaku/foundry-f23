# Market shift

### Create shift

[`ExchangeRouter.createShift`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/router/ExchangeRouter.sol#L213-L222)

```
1. Send GM token to shift vault
2. Send execution fee to shift vault
3. Create shift order

ExchangeRouter.createShift
└ ShiftHandler.createShift
    └ ShiftUtils.createShift
        ├ ShiftVault.recordTransferIn
        ├ ShiftVault.recordTransferIn
        └ ShiftStoreUtils.set
```

### Execute shift

[`ShiftHandler.executeShift`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/exchange/ShiftHandler.sol#L66-L94)

```
ShiftHandler.executeShift
├ ShiftStoreUtils.get
└ _executeShift
    └ ShiftUtils.executeShift
        ├ ShiftStoreUtils.remove
        ├ ExecuteWithdrawalUtils.executeWithdrawal
        ├ ShiftVault.recordTransferIn
        ├ ShiftVault.recordTransferIn
        └ ExecuteDepositUtils.executeDeposit
```
