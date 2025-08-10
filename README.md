# DeFi Aave V3 (3.3)

[contributors-shield]: https://img.shields.io/github/contributors/cyfrin/defi-aave-v3.svg?style=for-the-badge
[contributors-url]: https://github.com/cyfrin/defi-aave-v3/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/cyfrin/defi-aave-v3.svg?style=for-the-badge
[forks-url]: https://github.com/cyfrin/defi-aave-v3/network/members
[stars-shield]: https://img.shields.io/github/stars/cyfrin/defi-aave-v3.svg?style=for-the-badge
[stars-url]: https://github.com/cyfrin/defi-aave-v3/stargazers
[issues-shield]: https://img.shields.io/github/issues/cyfrin/defi-aave-v3.svg?style=for-the-badge
[issues-url]: https://github.com/cyfrin/defi-aave-v3/issues
[license-shield]: https://img.shields.io/github/license/cyfrin/defi-aave-v3.svg?style=for-the-badge
[license-url]: https://github.com/cyfrin/defi-aave-v3/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555

<div align="center">

[![Stargazers][stars-shield]][stars-url] [![Forks][forks-shield]][forks-url] [![Contributors][contributors-shield]][contributors-url] [![Issues][issues-shield]][issues-url] [![GPLv3 License][license-shield]][license-url]

<p align="center">
    <br />
    <a href="https://cyfrin.io/">
        <img src=".github/images/poweredbycyfrinbluehigher.png" width="145" alt=""/></a>
            <a href="https://updraft.cyfrin.io/courses/aave-v3">
        <img src=".github/images/coursebadge.png" width="242.3" alt=""/></a>
    <br />
</p>
</div>

This repository houses course resources and [discussions](https://github.com/Cyfrin/defi-aave-v3/discussions) for the course.

Please refer to this for an in-depth explanation of the content:

- [Website](https://updraft.cyfrin.io) - Join Cyfrin Updraft and enjoy 50+ hours of smart contract development courses
- [Twitter](https://twitter.com/CyfrinUpdraft) - Stay updated with the latest course releases
- [LinkedIn](https://www.linkedin.com/school/cyfrin-updraft/) - Add Updraft to your learning experiences
- [Discord](https://discord.gg/cyfrin) - Join a community of 3000+ developers and auditors
- [Codehawks](https://codehawks.com) - Smart contracts auditing competitions to help secure web3

## Introduction

- [Course intro](./notes/course-intro.md)
- [Setup](./notes/course-setup.md)

## Foundation

- [UI demo](https://app.aave.com/)
- [APY and APR](./notes/apr-apy.png)
- [Market forces](./notes/market-forces.png)
- [Utilization rate](./notes/utilization-rate.png)
- [Interest rate model - graph](https://www.desmos.com/calculator/2pfuulkndt)
- [Reserve](./notes/reserve.md)
- AToken and debt token
  - [Supply DAI](https://etherscan.io/tx/0x48237c5e7aaae5d35f36c1d8b66abf4cc5fc8d335dfa395f89b3b1627a2540c8)
  - [Borrow ETH](https://etherscan.io/tx/0xfe4b17b089b50bf9c2b00561061b4205e72bf9695c63e7fde31d54f299b9392f)
- Liquidity and borrow index
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

### Aave V3

- [App](https://app.aave.com/)
- [Docs](https://aave.com/docs)
- [GitHub aave-v3-origin](https://github.com/aave-dao/aave-v3-origin)
- [GitHub aave-v3-origin 3.3](https://github.com/aave-dao/aave-v3-origin/tree/v3.3.0)
- [GitHub aave v3 error codes](https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/libraries/helpers/Errors.sol)
- [Aave V3 book](https://calnix.gitbook.io/aave-book)
- [Pool - proxy](https://etherscan.io/address/0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2)

### Transactions

- [Supply rETH tx](https://etherscan.io/tx/0xc1120138b3aa3dc6a49ef7e84ecd17530c273e2442f83e47025d819d9a700743)
- [Supply ETH tx](https://etherscan.io/tx/0x21de14e5c58b9431a70b780893d01f0b82f07a0495d851d97fc0e85c64887610)
- [Borrow DAI tx](https://etherscan.io/tx/0x5e4deab9462bec720f883522d306ec306959cb3ae1ec2eaf0d55477eed01b5a4)
- [Repay DAI tx](https://etherscan.io/tx/0x1145e9815060164ef9234bdbc6d88db97ac5dda7b1e30732dc981145604e0373)
- [Withdraw rETH](https://etherscan.io/tx/0x7442ab56bfe90a189516f44846b93d25aa0dde3bbfba935429ac561ab34bc575)
- [Withdraw ETH](https://etherscan.io/tx/0x748e56cfaa10b6d629bd06badfdf83b337956e640523bbb1805901e11915c517)
- [Supply DAI](https://etherscan.io/tx/0x48237c5e7aaae5d35f36c1d8b66abf4cc5fc8d335dfa395f89b3b1627a2540c8)
- [Withdraw DAI](https://etherscan.io/tx/0x4e263e358db180ec478d61542a1126a47bba6d6fc0d5bb2b7b8cf83a8bdb11d3)
- [Borrow DAI](https://etherscan.io/tx/0x5e4deab9462bec720f883522d306ec306959cb3ae1ec2eaf0d55477eed01b5a4)
- [Repay DAI](https://etherscan.io/tx/0x1145e9815060164ef9234bdbc6d88db97ac5dda7b1e30732dc981145604e0373)
- [Borrow ETH](https://etherscan.io/tx/0xfe4b17b089b50bf9c2b00561061b4205e72bf9695c63e7fde31d54f299b9392f)
