# Profit and loss

[`Reader.getPositionInfo`]

[`ReaderPositionUtils.getPositionInfo`]

[`PositionUtils.getPositionPnlUsd`]

[`PositionPricingUtils.getPositionFees`]

```
pnl = position pnl - fees +/- funding fee +/- price impact
```

```
Long
(position.sizeInTokens * indexTokenPrice) - position.sizeInUsd

Short
position.sizeInUsd - (position.sizeInTokens * indexTokenPrice)
```
