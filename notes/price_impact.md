# Price impact

## Purpose

Keep the pools balanced between long and short.

If an action (swap, long, short, deposit liquidity)

- Reduces imbalance = positive impact -> rebate
- Increases imbalance = negative impact -> extra fee

## Swap

```
Imbalance for swap = |long tokens in pool USD - short tokens in pool USD|
Positive impact -> bonus to amount out
Negative impact -> fee to amount in
```

[`SwapUtils._swap`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/swap/SwapUtils.sol#L271-L337)

[`SwapPricingUtils.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/SwapPricingUtils.sol#L109-L166)

## Long and short

```
Imbalance for long and short = |long open interest - short open interest|
```

[`PositionPricingUtil.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PositionPricingUtils.sol#L159-L182)

```
Open
  Long
    Positive impact -> increase size delta in tokens -> lower execution price
    Negative impact -> decrease size delta in tokens -> higher execution price
  Short
    Positive impact -> decrease size delta in tokens -> higher execution price
    Negative impact -> increase size delta in tokens -> lower execution price
Close
  Positive impact -> receive token
  Negative impact -> pay from collateral
```

[`PositionUtils.getExecutionPriceForIncrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L621-L714)

[`PositionUtils.getPositionPnlUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L176-L233)

[`DecreasePositionCollateralUtils.processCollateral`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/DecreasePositionCollateralUtils.sol#L139-L173)

[`DecreasePositionCollateralUtils.processCollateral`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/DecreasePositionCollateralUtils.sol#L379-L386)

## Deposit liquidity

```
Imbalance for deposit liquidity = |long tokens in pool USD - short tokens in pool USD|
Positive impact -> mint additional market token
Negative impact -> fees deducted from deposit amounts
```

[`ExecuteDepositUtils._executeDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/deposit/ExecuteDepositUtils.sol#L399-L486)

## Same side

```
same side = long < short and next long < next short
            or
            long >= short and next long >= next short
```

## Cross over

```
cross over = not same side
```

## Price impact

[Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)

```
d0 = initial imbalance USD
d1 = next imbalance USD
e = exponent factor

# Same side
f = impact factor depends on positive or negative impact
same side price impact = d0 ^ e * f - d1 ^ e * f

# Cross over
p = positive impact factor
n = negative impact factor

p <= n

cross over price impact = d0 ^ e * p - d1 ^ e * n
```

[`SwapPricingUtils.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/SwapPricingUtils.sol#L109-L166)

[`PositionPricingUtils.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PositionPricingUtils.sol#L159-L182)

[`PricingUtils.getPriceImpactUsdForSameSideRebalance`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PricingUtils.sol#L61-L77)

[`PricingUtils.getPriceImpactUsdForCrossoverRebalance`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PricingUtils.sol#L88-L102)
