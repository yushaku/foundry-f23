# Borrowing fee

- Paid from position holder (trader) to liquidity provider.
- Discourages a user opening equal longs / shorts and unnecessarily taking up capacity

## How is borrowing fee calculated for trader?

[`MarketUtils.getBorrowingFees`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1708-L1715)

## How is borrowing fee updated for trader?

Increase or decrease in position increases pool amount

[`MarketUtils.updateCumulativeBorrowingFactor`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1417-L1440)

```
ExecuteOrderUtils.executeOrder
├ PositionUtils.updateFundingAndBorrowingState
└ processOrder
    └ IncreaseOrderUtils.processOrder
        └ IncreasePositionUtils.increasePosition
            ├ processCollateral
            │   ├ PositionPricingUtils.getPositionFees
            │   │  └ MarketUtils.getBorrowingFees
            │   └ MarketUtils.applyDeltaToPoolAmount
            ├ params.position.setCollateralAmount
            ├ MarketUtils.getCumulativeBorrowingFactor
            ├ PositionUtils.updateTotalBorrowing
            └ params.position.setBorrowingFactor
```

```
ExecuteOrderUtils.executeOrder
├ PositionUtils.updateFundingAndBorrowingState
└ processOrder
    └ DecreaseOrderUtils.processOrder
        └ DecreasePositionUtils.decreasePosition
            ├ DecreasePositionCollateralUtils.processCollateral
            │   ├ PositionPricingUtils.getPositionFees
            │   │  └ MarketUtils.getBorrowingFees
            │   └ MarketUtils.applyDeltaToPoolAmount
            ├ MarketUtils.getCumulativeBorrowingFactor
            ├ PositionUtils.updateTotalBorrowing
            ├ params.position.setBorrowingFactor
            └ params.position.setCollateralAmount
```

## How is borrowing fee rate calculated?

[`MarketUtils.updateCumulativeBorrowingFactor`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1417-L1440)

[`MarketUtils.getBorrowingFactorPerSecond`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L2368-L2430)

```
PositionUtils.updateFundingAndBorrowingState
└ MarketUtils.updateCumulativeBorrowingFactor
    ├ getNextCumulativeBorrowingFactor
    │    ├ getSecondsSinceCumulativeBorrowingFactorUpdated
    │    ├ getBorrowingFactorPerSecond
    │    │  ├ getOptimalUsageFactor
    │    │  ├ if optimal usage factor != 0
    │    │  │  └ getKinkBorrowingFactor
    │    │  │      └ getUsageFactor
    │    │  ├ getBorrowingExponentFactor
    │    │  └ getBorrowingFactor
    │    └ getCumulativeBorrowingFactor
    └ incrementCumulativeBorrowingFactor
```

```
if optimal usage factor = 0
    e = borrowing exponent factor
    r = reserve USD
    P = pool USD
    b = borrowing factor
    r^e / P * b
```

[`MarketUtils.getReservedUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1742-L1766)

[`MarketUtils.getUsageFactor`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L498-L518)

```
usage factor = max(reserve usage factor, open interest usage factor)
reserve usage factor = reserved USD / max reserve
max reserve = reserve factor * pool usd
open interest usage factor = open interest / max open interest
```

[`MarketUtils.getKinkBorrowingFactor`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L2432-L2471)

```
u = usage factor
u_o = optimal usage factor
b0 = base borrowing factor
b1 = above optimal usage borrowing factor

kink borrowing factor per second = b0 * u

if u > u_o
    kink borrowing factor per second += max(b1 - b0, 0) * (u - u_o) / (1 - u_o)
```

### How is borrowing claimed by LP?

Claimed from increased pool amount
