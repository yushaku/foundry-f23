# GLV deposit

### Create deposit

[`GlvRouter.createglvDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/router/GlvRouter.sol#L35-L41)

```
1. Send tokens to deposit GLV vault
2. Send execution fee to GLV vault
3. Create deposit order

GlvRouter.createGlvDeposit
└ GlvHandler.createGlvDeposit
    └ GlvDepositUtils.createGlvDeposit
        ├ GlvVault.recordTransferIn
        ├ GlvVault.recordTransferIn
        ├ GlvVault.recordTransferIn
        └ GlvDepositStoreUtils.set
```

### Execute deposit

[`GlvHandler.executeGlvDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/exchange/GlvHandler.sol#L44-L64)

```
GlvHandler
└ executeGlvDeposit
    ├ GlvDepositStoreUtils.get
    └ _executeGlvDeposit
        └ GlvDepositUtils.executeGlvDeposit
            ├ GlvDepositStoreUtils.remove
            ├ _processMarketDeposit
            │  └ ExecuteDepositUtils.executeDeposit
            ├ _getMintAmount
            └ GlvToken.mint
```
