# Forking tests

- **Unit tests**: Focus on isolating and testing individual smart contract functions or functionalities.
- **Integration tests**: Verify how a smart contract interacts with other contracts or external systems.
- **Forking tests**: Forking refers to creating a copy of a blockchain state at a specific point in time.
  This copy, called a fork, is then used to run tests in a simulated environment.
- **Staging tests**: Execute tests against a deployed smart contract on a staging environment before mainnet deployment.

## step to test

1. Create a .env file.
2. In the `.env` file create a new entry as follows:

```Solidity
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOURAPIKEYWILLGOHERE
```

1. Run `source .env` in your terminal;
2. Run `forge test --fork-url $SEPOLIA_RPC_URL`

```Solidity
Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testPriceFeedVersionIsAccurate() (gas: 14118)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.29s (536.03ms CPU time)
```

Nice!

Please keep in mind that forking uses the Alchemy API, it's not a good idea to run all your tests on a fork every single time. But, sometimes as in this case, you can't test without. It's very important that our test have a high **coverage**, to ensure all our code is battle tested.

### Coverage

Foundry provides a way to calculate the coverage. You can do that by calling `forge coverage`. This command displays which parts of your code are covered by tests. Read more about its options [here](https://book.getfoundry.sh/reference/forge/forge-coverage?highlight=coverage#forge-coverage).

```sh
forge coverage --fork-url $SEPOLIA_RPC_URL
```

```sh
Ran 3 tests for test/FundMe.t.sol:FundMeTest
[PASS] testMinimumDollarIsFive() (gas: 5759)
[PASS] testOwnerIsMsgSender() (gas: 8069)
[PASS] testPriceFeedVersionIsAccurate() (gas: 14539)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 1.91s (551.69ms CPU time)

Ran 1 test suite in 2.89s (1.91s CPU time): 3 tests passed, 0 failed, 0 skipped (3 total tests)
| File                      | % Lines       | % Statements  | % Branches    | % Funcs      |
| ------------------------- | ------------- | ------------- | ------------- | ------------ |
| script/DeployFundMe.s.sol | 0.00% (0/3)   | 0.00% (0/3)   | 100.00% (0/0) | 0.00% (0/1)  |
| src/FundMe.sol            | 21.43% (3/14) | 25.00% (5/20) | 0.00% (0/6)   | 33.33% (2/6) |
| src/PriceConverter.sol    | 0.00% (0/6)   | 0.00% (0/11)  | 100.00% (0/0) | 0.00% (0/2)  |
| Total                     | 13.04% (3/23) | 14.71% (5/34) | 0.00% (0/6)   | 22.22% (2/9) |
```

These are rookie numbers! Maybe 100% is not feasible, but 13% is as good as nothing. In the next lessons, we will up our game and increase these numbers!
