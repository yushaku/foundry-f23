# Virtual inventory

Virtual inventory is to help prevent price manipulation.

[`MarketUtils.getVirtualInventoryForSwaps`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1772-L1783)

[`MarketUtils.getVirtualInventoryForPositions`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1796-L1803)

### Swap

```
virtual inventory = long and short token amounts
```

### Position

```
virtual inventory >= 0 -> long open interest
                   < 0 -> short open interest
```
