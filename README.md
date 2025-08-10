# DeFi Aave V3.3

- [Avve app](https://app.aave.com/)

## Foundation

- [supply](./notes/supply.md)
- [APY and APR](./notes/apr-apy.png)
- [Market forces](./notes/market-forces.png)
- [Utilization rate](./notes/utilization-rate.png)
- [Interest rate model - graph](https://www.desmos.com/calculator/2pfuulkndt)
- [Reserve](./notes/reserve.md)
- [Scaled balance](./notes/scaled-balance.png)
- [Liquidity and borrow indexes code](./notes/liquidity-index.md)

## Contract Architecture

- [Contract architecture](./notes/arc.png)
- Supply
  - Execution flow
    - [Supply DAI](https://etherscan.io/tx/0x48237c5e7aaae5d35f36c1d8b66abf4cc5fc8d335dfa395f89b3b1627a2540c8)
  - Linear interest
  - [Exercises](./foundry/exercises/supply.md)
    - [Starter code](./foundry/src/exercises/Supply.sol)
    - [Solution](./foundry/src/solutions/Supply.sol)
- Borrow
  - Execution flow
    - [Borrow DAI](https://etherscan.io/tx/0x5e4deab9462bec720f883522d306ec306959cb3ae1ec2eaf0d55477eed01b5a4)
  - [Compound interest](./notes/binomial_expansion.ipynb)
  - [Reserve factor](./notes/reserve-factor.md)
  - [LTV](./notes/ltv.png)
  - [Liquidation threshold](./notes/liquidation-threshold.png)
  - [Health factor](./notes/health-factor.png)
  - [Exercises](./foundry/exercises/borrow.md)
    - [Starter code](./foundry/src/exercises/Borrow.sol)
    - [Solution](./foundry/src/solutions/Borrow.sol)
- Repay
  - Execution flow
    - [Repay DAI](https://etherscan.io/tx/0x1145e9815060164ef9234bdbc6d88db97ac5dda7b1e30732dc981145604e0373)
  - [Exercises](./foundry/exercises/repay.md)
    - [Starter code](./foundry/src/exercises/Repay.sol)
    - [Solution](./foundry/src/solutions/Repay.sol)
- Withdraw
  - Execution flow
    - [Withdraw DAI](https://etherscan.io/tx/0x4e263e358db180ec478d61542a1126a47bba6d6fc0d5bb2b7b8cf83a8bdb11d3)
  - [Exercises](./foundry/exercises/withdraw.md)
    - [Starter code](./foundry/src/exercises/Withdraw.sol)
    - [Solution](./foundry/src/solutions/Withdraw.sol)
- Liquidation
  - [Close factor](./notes/close-factor.png)
  - [Math](./notes/liquidation.png)
  - Why my position is not liquidated?
  - [Exercises](./foundry/exercises/liquidate.md)
    - [Starter code](./foundry/src/exercises/Liquidate.sol)
    - [Solution](./foundry/src/solutions/Liquidate.sol)
- Flash loan simple
  - [Execution flow](./notes/flash-loan.md)
  - [Exercises](./foundry/exercises/flash.md)
    - [Starter code](./foundry/src/exercises/Flash.sol)
    - [Solution](./foundry/src/solutions/Flash.sol)

## Application

- [Long leverage](./notes/long.png)
- [Short selling](./notes/short.png)
- [Flash leverage](https://updraft.cyfrin.io/courses/rocket-pool-reth-integration)
- [Exercises](./foundry/exercises/long-short.md)
  - [Starter code](./foundry/src/exercises/LongShort.sol)
  - [Solution](./foundry/src/solutions/LongShort.sol)

## Resources

- [App](https://app.aave.com/)
- [Docs](https://aave.com/docs)
- [GitHub aave-v3-origin](https://github.com/aave-dao/aave-v3-origin)
- [GitHub aave-v3-origin 3.3](https://github.com/aave-dao/aave-v3-origin/tree/v3.3.0)
- [GitHub aave v3 error codes](https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/libraries/helpers/Errors.sol)
- [Aave V3 book](https://calnix.gitbook.io/aave-book)
- [Pool - proxy](https://etherscan.io/address/0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2)
