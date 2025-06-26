# GMX V2

## What will you learn?

- What is GMX V2 and how it works
- DeFi terminologies
  - Perpetual swap
  - Leverage
  - Long and short
  - Funding fee
- Write smart contracts that interact with GMX V2

## Why should you take this course?

- Expand DeFi knowledge
- Audit contests and bug bounties
- Build application that integrates with GMX V2
- Build your own perpetual exchange

## Prerequisites

- DeFi basic terminologies
  - DAI, USDC, WETH, WBTC, ERC20 decimals, AMM, price oracle, Arbitrum, etc..
- Intermediate to advanced Solidity
  - Solidity `library` (State changing calls through a `library` uses `delegatecall`)
  - [`multicall`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/utils/PayableMulticall.sol#L18-L33)
- Advanced Foundry
  - Test on fork
  - Console log to debug

## Getting Started

- [Foundry setup](./foundry/README.md)
- Use transcation debugger such as [tenderly.co](https://dashboard.tenderly.co/explorer) to debug [transactions](#transactions)
- `git clone` [gmx-synthetics](https://github.com/gmx-io/gmx-synthetics)
- `git clone` [gmx-contracts](https://github.com/gmx-io/gmx-contracts)
- All course notes can be found under [notes](./notes)
- Ask questions on [discussions](https://github.com/Cyfrin/defi-gmx-v2/discussions)

## Introduction

- Quick guide on how to bridge ETH to Arbitrum
  - [Arbitrum bridge](https://bridge.arbitrum.io/)
  - [tx - Deposit ETH to Arbitrum One](https://etherscan.io/tx/0x1752e3449694e4c3d516093294f39a2a3576198db7d3af3975704b0a339bf4b1)
  - [tx - Deposit DAI to Arbitrum One](https://etherscan.io/tx/0xb15ea04494164f2d1dd6a12222010c65f496190e69f6acd909d0b6c80fbf37cb)

## Foundation

- [What is GMX?](https://gmx.io)
- [How GMX works](./notes/gmx_v2.png)
- [Perpetual swap](./notes/terms/perp.png)
- [Long and short](./notes/terms/perp.png)
- [Leverage](./notes/terms/leverage.png)
- [Purpose of leverage](./notes/terms/leverage.png)
- [Markets](./notes/terms/market.png)
- [2 types of market](./notes/terms/market.png)
- [Liquidity provider](./notes/terms/lp.png)
- [Position size](./notes/terms/position_size.png)
- [Examples of position profit and loss](./notes/terms/position_size.png)
- [Liquidation](./notes/terms/liquidation.png)
- [Open interest](./notes/terms/open_interest.png)
- [Funding fee](./notes/terms/funding_fee.png)
- [4 types of open interest](./notes/terms/open_interest.png)
- [Contract architecture](./notes/gmx_v2_contracts.png)

## Trading

- [Graph - payoffs for positions](https://www.desmos.com/calculator/ieq40vs9ve)
- Fees
  - [Purpose of price impact](./notes/price_impact.md)
  - [Price impacts for swap, positions and liquidity](./notes/price_impact.md)
  - [Price impact formula](./notes/price_impact.md)
  - [Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)
  - [Virtual inventory](./notes/virtual_inventory.md)
  - [Swap fee on amount in](./notes/swap/swap_fees.md)
  - [Position](./notes/position/position_fees.md)
  - [Borrowing fee math](./notes/position/borrowing_fee.png)
  - [How to update borrowing fee](./notes/position/borrowing_fee.md)
  - [Graph - kink borrowing factor](https://www.desmos.com/calculator/9khv07nrfb)
  - [Funding fee math](./notes/position/funding_fee.png)
  - [How is funding fee updated](./notes/position/funding_fee.md)
  - [How is funding factor per second calculated](./notes/position/funding_fee.md)
- [Order types](./notes/order_types.md)
- [Market swap](./notes/swap/swap.md)
  - [Token flow](./notes/swap/execute_swap.png)
  - [tx - Swap DAI to ETH part 1](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
  - [tx - Swap DAI to ETH part 2](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
- Limit swap
  - [tx - Limit order swap 2.63 USDC to ETH at $2780 part 1](https://arbiscan.io/tx/0x5a55b926aadaa832a42c55a4a60b0008193c773767e7289cdeb7eca0e1433595)
  - [tx - Limit order swap 2.63 USDC to ETH at $2780 part 2](https://arbiscan.io/tx/0x2306c6c8300a10a4e59c6dcc04513c84c0d2469172beb5c8f9cf1820eba308d0)
- Long
  - [Open](./notes/position/market_increase.md)
    - [tx - Open long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0xcac1ce9014aafcd3d8ae89c27cfd4866de36ff010ded5344a65bd4034d358413)
    - [tx - Open long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0x29d95557ef789fd6d9031c739a29dd5adc112f3ff8aab0524cd6aa9ddfc4e278)
  - [Close](./notes/position/market_decrease.md)
    - [tx - Close long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0x13cdef0acc7d4017f82df308f0f628996b707396182fc2a2042e78b0ebc4657d)
    - [tx - Close long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0xf5f5d293ef7bdc6893941cda6a6fd57d67a20876a175aa1e424af9442868bb47)
- Short
  - [tx - Open short 0.01 ETH part 1](https://arbiscan.io/tx/0x15f4bb54997d8efbf0816313e64120fe5bf89ab31fe78f4a647f47b61b629eea)
  - [tx - Open short 0.01 ETH part 2](https://arbiscan.io/tx/0x7039c81c3f14f54fbfb45c337fb13e4513b8e795a2d9237b66b2b191e717121e)
  - [tx - Close short 0.01 ETH part 1](https://arbiscan.io/tx/0x3825aab5d7bbfac2b68f75c77c1ff55e684496844a8dd605dc43a1348efceb22)
  - [tx - Close short 0.01 ETH part 2](https://arbiscan.io/tx/0x8ade23d7ad7ee6fb589a0d04724ee8c64f20e92e32688739e0c049b510c690f0)
- TP and SL
  - [tx - Short ETH 0.01 ~ TP $2200 SL $2260 part 1](https://arbiscan.io/tx/0xfb4a9ddd2b80a4e7f739c0281a3869d89ee3cb96fe796446511098eb917016a4)
  - [tx - Short ETH 0.01 ~ TP $2200 SL $2260 part 2](https://arbiscan.io/tx/0x9a32d9750bc14d77756ab9ebae1141c2b4845f44cdf2091fc74b7df174b32887)
  - [tx - Take profit short ETH 0.01 ~ TP $2200 SL $2260](https://arbiscan.io/tx/0x612165df3da2fd87dc0b6c86e76b7d69a5900208da025a80ad275c1319a012c2)
- [Claim funding fees](./notes/position/claim_funding_fees.md)
  - [tx - Claim funding fees](https://arbiscan.io/tx/0x4415830b1a12882409df17e80be26da8c20e4cc929f1764046ca3aae3ca8339e)
- Foundry exercises
  - [Market swap](./foundry/exercises/market_swap.md)
    - [Starter code](./foundry/src/exercises/MarketSwap.sol)
    - [Solution](./foundry/src/solutions/MarketSwap.sol)
  - [Limit swap](./foundry/exercises/limit_swap.md)
    - [Starter code](./foundry/src/exercises/LimitSwap.sol)
    - [Solution](./foundry/src/solutions/LimitSwap.sol)
  - [Long position](./foundry/exercises/long.md)
    - [Starter code](./foundry/src/exercises/Long.sol)
    - [Solution](./foundry/src/solutions/Long.sol)
  - [Short position](./foundry/exercises/short.md)
    - [Starter code](./foundry/src/exercises/Short.sol)
    - [Solution](./foundry/src/solutions/Short.sol)
  - [Claim funding fees](./foundry/exercises/claim_funding_fees.md)
    - [Starter code](./foundry/src/exercises/ClaimFundingFees.sol)
    - [Solution](./foundry/src/solutions/ClaimFundingFees.sol)
  - [Take profit and stop loss](./foundry/exercises/take_profit_stop_loss.md)
    - [Starter code](./foundry/src/exercises/TakeProfitAndStopLoss.sol)
    - [Solution](./foundry/src/solutions/TakeProfitAndStopLoss.sol)

## Liquidation

- [When executed?](./notes/liquidation/liquidation.md)
- [Approximate liquidation price](./notes/liquidation/liq_price_approx.png)

## Liquidity

- GM pool
  - [Token price](./notes/liquidity/market_token_price.md)
  - [Fees](./notes/liquidity/market_liquidity_fees.md)
  - [Mint](./notes/liquidity/market_deposit.md)
    - [tx - Buy GM ETH/USD part 1](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
    - [tx - Buy GM ETH/USD part 2](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
  - [Burn](./notes/liquidity/market_withdraw.md)
    - [tx - Sell GM ETH/USD part 1](https://arbiscan.io/tx/0xda4bc1d39be6ea85f8323875cbc4920aa33d0af38d7af2eb3f3dd03d174ae98e)
    - [tx - Sell GM ETH/USD part 2](https://arbiscan.io/tx/0xbdc46442f47149089f4976190a97c81bf476eb43b0478689e0ac918a9a502641)
  - [Shift](./notes/liquidity/market_shift.md)
    - [tx - Shift ETH/USDC to LDO/USD part 1](https://arbiscan.io/tx/0xaa88b76cd39de8931bdfb3cce46984f634ecfe6ca88b40965191f9b05b50605d)
    - [tx - Shift ETH/USDC to LDO/USD part 2](https://arbiscan.io/tx/0x6b6db0a76a506b76c8cf517f59ca8a506b0f7e8e8f36f578a92ce7da0ddd38dc)
- GLV vault
  - [Token pricing](./notes/liquidity/glv_token_price.md)
  - [Fees](./notes/liquidity/glv_liquidity_fees.md)
  - [Mint](./notes/liquidity/glv_deposit.md)
    - [tx - Buy GLV part 1](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
    - [tx - Buy GLV part 2](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
  - [Burn](./notes/liquidity/glv_withdraw.md)
    - [tx - Sell GLV part 1](https://arbiscan.io/tx/0xb60ed4fa2252dae32f8252f5702c3caf0cd2f074a9e9b41eaaaae2cea3f760c6)
    - [tx - Sell GLV part 2](https://arbiscan.io/tx/0x5120cf011c75d9b67bdffa99c4e3c6fffb5e8bb428f0080fc7ccded361bf98e6)
- [ ] Foundry exercises
  - [GM pool liquidity](./foundry/exercises/gm_liquidity.md)
    - [Starter code](./foundry/src/exercises/GmLiquidity.sol)
    - [Solution](./foundry/src/solutions/GmLiquidity.sol)
  - [GLV vault liquidity](./foundry/exercises/glv_liquidity.md)
    - [Starter code](./foundry/src/exercises/GlvLiquidity.sol)
    - [Solution](./foundry/src/solutions/GlvLiquidity.sol)

## GMX token

- [GMX](./notes/gmx_token.md)
  - [tx - Stake GMX](https://arbiscan.io/tx/0x0ed2a66323713c2e78dd53750612f3e9bcc97f2f8c02633a433a413889142067)
  - [tx - Unstake GMX](https://arbiscan.io/tx/0x2bbfefc59c295349405a86b08f9bd68b020e49836e9775de74e442908732678f)
  - [tx - Claim rewards](https://arbiscan.io/tx/0x23f1f338dc2456cf476692f34ea00838a1e621f8fd2aff330927edf256de8b1d)
  - [tx - Delegate](https://arbiscan.io/tx/0x245404338a81a8faccddf6ad8e944928bac6b687db8d7e217e47fdde94abd84f)
  - Foundry exercises
    - [GMX](./foundry/exercises/stake.md)
      - [Starter code](./foundry/src/exercises/Stake.sol)
      - [Solution](./foundry/src/solutions/Stake.sol)

## Application

- [Application architecture](./notes/app.png)
- [Callback](./notes/callback.md)
- Foundry exercises
  - [`GMXHelper`](./foundry/exercises/app/gmx_helper.md)
    - [Starter code](./foundry/src/exercises/app/GmxHelper.sol)
    - [Solution](./foundry/src/solutions/app/GmxHelper.sol)
  - [`Strategy`](./foundry/exercises/app/strategy.md)
    - [Starter code](./foundry/src/exercises/app/Strategy.sol)
    - [Solution](./foundry/src/solutions/app/Strategy.sol)
  - [`WithdrawCallback`](./foundry/exercises/app/withdraw_callback.md)
    - [Starter code](./foundry/src/exercises/app/WithdrawCallback.sol)
    - [Solution](./foundry/src/solutions/app/WithdrawCallback.sol)
  - [`Vault`](./foundry/exercises/app/vault.md)
    - [Starter code](./foundry/src/exercises/app/Vault.sol)
    - [Solution](./foundry/src/solutions/app/Vault.sol)

## Resources

### Transactions

Market swaps

- [Swap DAI to ETH part 1](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
- [Swap DAI to ETH part 2](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
- [Swap DAI to GMX part 1](https://arbiscan.io/tx/0x35572d81e52d1a2f254bcdeb30232e4fae9c4fc178f8b92240f9169951f70c36)
- [Swap DAI to GMX part 2](https://arbiscan.io/tx/0xb44af9795a4f728a3813aed7cafc7a66a5e4b6c12a2e1cfc3999be1ff960e9cd)

Limit swaps

- [Limit order swap 2.63 USDC to ETH at $2780 part 1](https://arbiscan.io/tx/0x5a55b926aadaa832a42c55a4a60b0008193c773767e7289cdeb7eca0e1433595)
- [Limit order swap 2.63 USDC to ETH at $2780 part 2](https://arbiscan.io/tx/0x2306c6c8300a10a4e59c6dcc04513c84c0d2469172beb5c8f9cf1820eba308d0)

Trades

- [Long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0xcac1ce9014aafcd3d8ae89c27cfd4866de36ff010ded5344a65bd4034d358413)
- [Long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0x29d95557ef789fd6d9031c739a29dd5adc112f3ff8aab0524cd6aa9ddfc4e278)
- [Close long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0x13cdef0acc7d4017f82df308f0f628996b707396182fc2a2042e78b0ebc4657d)
- [Close long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0xf5f5d293ef7bdc6893941cda6a6fd57d67a20876a175aa1e424af9442868bb47)

- [Short 0.01 ETH part 1](https://arbiscan.io/tx/0x15f4bb54997d8efbf0816313e64120fe5bf89ab31fe78f4a647f47b61b629eea)
- [Short 0.01 ETH part 2](https://arbiscan.io/tx/0x7039c81c3f14f54fbfb45c337fb13e4513b8e795a2d9237b66b2b191e717121e)
- [Close short 0.01 ETH part 1](https://arbiscan.io/tx/0x3825aab5d7bbfac2b68f75c77c1ff55e684496844a8dd605dc43a1348efceb22)
- [Close short 0.01 ETH part 2](https://arbiscan.io/tx/0x8ade23d7ad7ee6fb589a0d04724ee8c64f20e92e32688739e0c049b510c690f0)

- [Short ETH 0.01 ~ TP $2200 SL $2260 part 1](https://arbiscan.io/tx/0xfb4a9ddd2b80a4e7f739c0281a3869d89ee3cb96fe796446511098eb917016a4)
- [Short ETH 0.01 ~ TP $2200 SL $2260 part 2](https://arbiscan.io/tx/0x9a32d9750bc14d77756ab9ebae1141c2b4845f44cdf2091fc74b7df174b32887)
- [Take profit short ETH 0.01 ~ TP $2200 SL $2260](https://arbiscan.io/tx/0x612165df3da2fd87dc0b6c86e76b7d69a5900208da025a80ad275c1319a012c2)

- [Claim funding fees](https://arbiscan.io/tx/0x4415830b1a12882409df17e80be26da8c20e4cc929f1764046ca3aae3ca8339e)

Liquidation

- [Liquidation](https://arbiscan.io/tx/0xa379337b09d07c3fa4c648b5c82567f83102a60f64693ef8106c6782a3791f14)

Liquidity

- [Buy GLV part 1](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
- [Buy GLV part 2](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
- [Sell GLV part 1](https://arbiscan.io/tx/0xb60ed4fa2252dae32f8252f5702c3caf0cd2f074a9e9b41eaaaae2cea3f760c6)
- [Sell GLV part 2](https://arbiscan.io/tx/0x5120cf011c75d9b67bdffa99c4e3c6fffb5e8bb428f0080fc7ccded361bf98e6)
- [Buy GM ETH/USD part 1](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
- [Buy GM ETH/USD part 2](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
- [Sell GM ETH/USD part 1](https://arbiscan.io/tx/0xda4bc1d39be6ea85f8323875cbc4920aa33d0af38d7af2eb3f3dd03d174ae98e)
- [Sell GM ETH/USD part 2](https://arbiscan.io/tx/0xbdc46442f47149089f4976190a97c81bf476eb43b0478689e0ac918a9a502641)
- [Buy BTC/USDC GLV part 1](https://arbiscan.io/tx/0x87ed238503646ef7d7045ce639efd59845db94384a00d37aedc174d52050eb83)
- [Buy BTC/USDC GLV part 2](https://arbiscan.io/tx/0x3f0c373aa132815204574ed7981c584d4f044eb2c00a160b7dd992822de66763)
- [Buy BTC/USDC GM part 1](https://arbiscan.io/tx/0xef88d101a155ffd16427fc78d50e6028d612c8bc1e8d46a7810d53882f705f91)
- [Buy BTC/USDC GM part 2](https://arbiscan.io/tx/0x54357ec00e44fa8d3d701368af4a3979a28dd2383b9eb5a3f299253e8ce217a1)
- [Sell BTC/USDC GM part 1](https://arbiscan.io/tx/0xae14c5e75e5f5e5669570fc8e4d288ce7e58aeaa49174f37c4a4588bc3d04aac)
- [Sell BTC/USDC GM part 2](https://arbiscan.io/tx/0xac64686c30e67f7eae3576be759dbaef774122601ebc0c15c8cf9001fb530627)
- [Shift ETH/USDC to LDO/USD part 1](https://arbiscan.io/tx/0xaa88b76cd39de8931bdfb3cce46984f634ecfe6ca88b40965191f9b05b50605d)
- [Shift ETH/USDC to LDO/USD part 2](https://arbiscan.io/tx/0x6b6db0a76a506b76c8cf517f59ca8a506b0f7e8e8f36f578a92ce7da0ddd38dc)

Stake

- [Stake GMX](https://arbiscan.io/tx/0x0ed2a66323713c2e78dd53750612f3e9bcc97f2f8c02633a433a413889142067)
- [Unstake GMX](https://arbiscan.io/tx/0x2bbfefc59c295349405a86b08f9bd68b020e49836e9775de74e442908732678f)
- [Claim rewards](https://arbiscan.io/tx/0x23f1f338dc2456cf476692f34ea00838a1e621f8fd2aff330927edf256de8b1d)
- [Delegate](https://arbiscan.io/tx/0x245404338a81a8faccddf6ad8e944928bac6b687db8d7e217e47fdde94abd84f)

Bridge from ETH mainnet to Arbitrum

- [Deposit ETH to Arbitrum One](https://etherscan.io/tx/0x1752e3449694e4c3d516093294f39a2a3576198db7d3af3975704b0a339bf4b1)
- [Deposit DAI to Arbitrum One](https://etherscan.io/tx/0xb15ea04494164f2d1dd6a12222010c65f496190e69f6acd909d0b6c80fbf37cb)

### GMX

- [GMX](https://gmx.io/)
- [GMX app](https://app.gmx.io/)
- [GMX doc](https://docs.gmx.io/docs)
- [GMX GitHub gmx-synthetics](https://github.com/gmx-io/gmx-synthetics)
- [GMX GitHub gmx-contracts](https://github.com/gmx-io/gmx-contracts)
- [GMX delegatees](https://www.tally.xyz/gov/gmx/delegates)
- [Tenderly](https://tenderly.co)
- [Chainlink providers](https://docs.chain.link/data-feeds/price-feeds/addresses?network=arbitrum&page=1)

### Arbitrum

- [Arbitrum](https://arbitrum.io/)
- [Arbitrum bridge](https://bridge.arbitrum.io/)
