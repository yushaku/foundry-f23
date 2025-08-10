# Liquidation

### Condition

[`ValidationLogic.validateLiquidationCall`](https://github.com/aave-dao/aave-v3-origin/blob/5431379f8beb4d7128c84a81ced3917d856efa84/src/contracts/protocol/libraries/logic/ValidationLogic.sol#L379-L424)

```
health factor < liquidation threshold (0.95 or 1)
```

### Close factor

Percentange of debt that can be repaid

Close factor between 1 and 0.5

### How much debt to repay?

[`LiquidationLogic.executeLiquidationCall`](https://github.com/aave-dao/aave-v3-origin/blob/5431379f8beb4d7128c84a81ced3917d856efa84/src/contracts/protocol/libraries/logic/LiquidationLogic.sol#L199-L437)

```
max liquidatable debt (specific to a token)

default
  max liquidatable debt = user's debt (specific to a token)

if debt and collateral >= MIN_BASE_MAX_CLOSE_FACTOR_THRESHOLD (2000 USD)
   and health factor is above CLOSE_FACTOR_HF_THRESHOLD (0.95)
   and user's debt (specific to a token) USD > total user's debt USD * DEFAULT_LIQUIDATION_CLOSE_FACTOR (0.5)
then
  max liquidatable debt = total user's debt USD * DEFAULT_LIQUIDATION_CLOSE_FACTOR / debt token price
```

### How much collateral to liquidate?

[`LiquidationLogic._calculateAvailableCollateralToLiquidate`](https://github.com/aave-dao/aave-v3-origin/blob/5431379f8beb4d7128c84a81ced3917d856efa84/src/contracts/protocol/libraries/logic/LiquidationLogic.sol#L633-L684)

```
base collateral = debt token price * debt to cover / collateral token price

max collateral = base collateral * liquidation bonus

if max collateral > user's collateral balance
  collateral to liquidate = user's collateral balance
  debt to repay = user's collateral balance * collateral token price / debt token price / liquidation bonus

bonus collateral = collateral to liquidate * (1 - 1 / liquidation bonus)
                 = collateral to liquidate with liquidation bonus - collateral to liquidate without liquidation bonus

protocol fee = bonus collateral * protocol fee percentage
```

### Dust prevention

[MIN_LEFTOVER_BASE](https://github.com/aave-dao/aave-v3-origin/blob/5431379f8beb4d7128c84a81ced3917d856efa84/src/contracts/protocol/libraries/logic/LiquidationLogic.sol#L320-L344)

```
// to prevent accumulation of dust on the protocol, it is enforced that you either
// 1. liquidate all debt
// 2. liquidate all collateral
// 3. leave more than MIN_LEFTOVER_BASE of collateral & debt

MIN_LEFTOVER_BASE = MIN_BASE_MAX_CLOSE_FACTOR_THRESHOLD / 2;
                  = 1000 USD
```
