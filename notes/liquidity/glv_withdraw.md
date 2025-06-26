# GLV withdraw

### Create withdrawal

[`GlvRouter.createGlvWithdrawal`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/router/GlvRouter.sol#L70-L76)

```
1. Send GLV token to GLV vault
2. Send execution fee to GLV vault
3. Create withdrawal order

GlvRouter.createGlvWithdrawal
└ GlvHandler.createGlvWithdrawal
    └ GlvWithdrawalUtils.createGlvWithdrawal
        ├ GlvVault.recordTransferIn
        └ GGlvWithdrawalStoreUtils.set
```

### Execute withdrawal

[`GlvHandler.executeGlvWithdrawal`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/exchange/GlvHandler.sol#L140-L164)

```
GlvHandler
└ executeGlvWithdrawal
    ├ GlvDepositStoreUtils.get
    └ _executeGlvWithdrawal
        └ GlvWithdrawalUtils.executeGlvWithdrawal
            ├ GlvWithdrawalStoreUtils.remove
            └ _processMarketWithdrawal
               ├ Glv.transferOut
               └ ExecuteWithdrawalUtils.executeWithdrawal
```
