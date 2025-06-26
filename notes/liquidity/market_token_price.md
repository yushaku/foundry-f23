# Market token price

[`MarketUtils.getMarketTokenPrice`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L135-L165)

[`MarketUtils.usdToMarketTokenAmount`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L2602-L2621)

[`MarketUtils.getPoolValueInfo`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L274-L370)

```
LP token price = pool value USD / market token total supply

pool value USD = USD values of long + short + fraction of pending borrowing fees - pnl - position impact pool
```
