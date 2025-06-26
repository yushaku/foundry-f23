# Swap fee

[`SwapPricingUtils.getSwapFees`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/SwapPricingUtils.sol#L256-L299)

```
a = swap -> amount in
  = deposit -> ammount in
  = withdraw -> long and short amount out
f = fee factor (different for price impact and deposit, withdraw, swap, etc...)
u = UI fee factor

fee = f * a  + u * a
```
