# Flash loan

[`Pool.flashLoanSimple`](https://github.com/aave-dao/aave-v3-origin/blob/5431379f8beb4d7128c84a81ced3917d856efa84/src/contracts/protocol/pool/Pool.sol#L413-L430)

```shell
Pool.flashLoanSimple
└── FlashLoanLogic.executeFlashLoanSimple
    ├── IAToken.transferUnderlyingTo
    ├── IFlashLoanSimpleReceiver.executeOperation
    └── _handleFlashLoanRepayment
        └── IERC20.safeTransferFrom
```
