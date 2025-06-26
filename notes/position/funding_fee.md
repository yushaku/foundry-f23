# Funding fee

## Purpose

- Incentivise the balancing of long and short positions
- Side with larger open interest pays a funding fee to the side with the smaller open interest
- Balances long and short demands
  - Traders pay each other instead of LPs directly covering trader profits

## How is funding fee rate calculated?

[`MarketUtils.getNextFundingFactorPerSecond`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L1261-L1385)

Funding factor per second

```
F = funding factor per second
L = Long open interest
S = Short open interest
e = Funding exponent factor

Fi = Funding increase factor per sec
Fd = Funding decrease factor per sec
F_min = min funding factor per sec
F_max = max funding factor per sec
F_market = Funding factor for this market

f = |L - S| ^ e / (L + S)

if Fi = 0
   F = min(f * F_market, F_max)

F0 = Saved funding factor per second
F0 > 0 = longs pay shorts
F0 < 0 = shorts pay longs

Ts = Threshold for stable funding
Td = Threshold for decrease funding

if (F0 > 0 and L > S) or (F0 < 0 and L < S)
   if f > Ts
      increase funding rate
   else if f < Td
      decrease funding rate
else
   increase funding rate

if funding rate increase
   F = F0 +/- f * Fi * dt (sign depends on direction of next funding)

if funding rate decrease
   if |F0| <= Fd * dt
      F = F0 / |F0|
   else
      F = (|F0| - Fd * dt) * F0 / |F0|

s = F / |F|
F = s * min(|F|, F_max)
F = s * max(|F|, F_min)
```

## How is funding fee updated for trader?

```
ExecuteOrderUtils.executeOrder
├─ PositionUtils.updateFundingAndBorrowingState (update funding fee)
│  └─ MarketUtils.updateFundingState
└─ processOrder
   └─ IncreaseOrderUtils.processOrder
      └─ IncreasePositionUtils.increasePosition
         ├─ if position.sizeInUsd = 0 (set funding fee to latest for new position)
         │   ├─ position.setFundingFeeAmountPerSize
         │   ├─ position.setLongTokenClaimableFundingAmountPerSize
         │   └─ position.setShortTokenClaimableFundingAmountPerSize
         ├─ processCollateral
         │   └─ PositionPricingUtils.getPositionFees
         │      ├─ MarketUtils.getFundingFeeAmountPerSize (get latest funding fees for position)
         │      ├─ MarketUtils.getClaimableFundingAmountPerSize
         │      ├─ MarketUtils.getClaimableFundingAmountPerSize
         │      └─ getFundingFees (calculate funding fees and claimable fees)
         │         ├─ MarketUtils.getFundingAmount
         │         ├─ MarketUtils.getFundingAmount
         │         └─ MarketUtils.getFundingAmount
         ├─ position.setCollateralAmount
         ├─ PositionUtils.incrementClaimableFundingAmount (store claimable funding fees)
         │   └─ MarketUtils.incrementClaimableFundingAmount
         ├─ position.setFundingFeeAmountPerSize (update funding fees to latest)
         ├─ position.setLongTokenClaimableFundingAmountPerSize
         └─ position.setShortTokenClaimableFundingAmountPerSize

ExecuteOrderUtils.executeOrder
├─ PositionUtils.updateFundingAndBorrowingState (update funding fee)
│  └─ MarketUtils.updateFundingState
└─ processOrder
   └─ DecreaseOrderUtils.processOrder
      └─ DecreasePositionUtils.decreasePosition
         ├─ DecreasePositionCollateralUtils.processCollateral
         │   └─ PositionPricingUtils.getPositionFees
         ├─ position.setCollateralAmount
         ├─ PositionUtils.incrementClaimableFundingAmount
         ├─ position.setFundingFeeAmountPerSize
         ├─ position.setLongTokenClaimableFundingAmountPerSize
         └─ position.setShortTokenClaimableFundingAmountPerSize

MarketUtils.updateFundingState
├─ getNextFundingAmountPerSize
│  ├─ getOpenInterest
│  ├─ getOpenInterest
│  ├─ getOpenInterest
│  ├─ getOpenInterest
│  ├─ getSecondsSinceFundingUpdated
│  ├─ getNextFundingFactorPerSecond
│  ├─ getFundingAmountPerSizeDelta
│  ├─ getFundingAmountPerSizeDelta
│  ├─ getFundingAmountPerSizeDelta
│  └─ getFundingAmountPerSizeDelta
├─ applyDeltaToFundingFeeAmountPerSize
├─ applyDeltaToClaimableFundingAmountPerSize
└─ setSavedFundingFactorPerSecond

```

## How is funding fee claimed by LP?

Claim fees from increased pool amount

```
ExchangeRouter.claimFundingFees
└─ for loop for each market
   └─ MarketUtils.claimFundingFees
      ├─ Keys.claimableFundingAmountKey(market, token, account);
      ├─ DataStore.getUint(key)
      ├─ DataStore.setUint(key, 0)
      ├─ DataStore.decrementUint
      └─ MarketToken.transferOut
```
