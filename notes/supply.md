# Aave V3

## Concepts

Aave V3 is a **decentralized liquidity protocol** where users can participate as suppliers (lenders) or borrowers.

- _Lending_: Users deposit their crypto into pools. These supplied assets accrue interest over time.
- _Borrowing_: Users can borrow assets from pools, provided they supply sufficient collateral. Borrowers pay interest on their loans.
- _Collateral_: Assets supplied by a user that are designated to secure any loans they take.
- _Interest Dynamics_: The interest earned by suppliers is directly funded by the interest paid by borrowers within the protocol.

## The Health Factor

It represents the safety of your loan position relative to your collateral.

- _HF > 1.0_: Your position is considered safe and overcollateralized.
- _HF ≤ 1.0_: Your position is undercollateralized and at risk of liquidation. If it drops to 1.0 or below, liquidators can repay a portion of your debt and claim a corresponding amount of your collateral, plus a penalty.

### Factors Influencing Health Factor:

- Increases HF:

  - Supplying more assets (especially if used as collateral).
  - Repaying borrowed assets.
  - If the value of your supplied collateral increases significantly relative to your debt.

- Decreases HF:

  - Borrowing assets.
  - Withdrawing collateral.
  - If the value of your supplied collateral decreases significantly, or the value of your borrowed assets increases significantly.

## Understanding Supply APY vs. APR

- Supply APY (Annual Percentage Yield): The annualized interest rate suppliers earn, including the effects of compounding interest (e.g., 2.57% for DAI). APY reflects the actual return if interest is periodically re-invested or compounded.

- Supply APR (Annual Percentage Rate): The annualized interest rate suppliers earn, without accounting for compounding. APY will generally be slightly higher than APR if interest compounds.
