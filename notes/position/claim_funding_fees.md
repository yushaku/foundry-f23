# Claim funding fees

```
ExchangeRouter.claimFundingFees
└─ for loop for each market
   └─ MarketUtils.claimFundingFees
      ├─ Keys.claimableFundingAmountKey
      ├─ DataStore.getUint
      ├─ DataStore.setUint
      ├─ DataStore.decrementUint
      └─ MarketToken.transferOut
```
