## Foundry

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

```shell
$ forge build
$ forge test
$ forge fmt        # format
$ forge snapshot   # Gas Snapshots
```

## install dependency packages

```sh
forge install smartcontractkit/chainlink-brownie-contracts@0.6.1
forge install Cyfrin/foundry-devops
```

## store private key in keystore

Encrypting your Keys Using ERC2335

```sh
cast wallet import nameOfAccountGoesHere --interactive

# output: `nameOfAccountGoesHere` keystore was saved successfully.
#          Address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

Ideally, you don't do this in your VS Code.

You will be asked for your `private key` and a `password` to secure it. You will do this only once, which is amazing!

```sh
forge script script/DeploySimpleStorage.s.sol \
--rpc-url $RPC_URL \
--broadcast \
--account nameOfAccountGoesHere \
--sender 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

You will be asked for your `password`. You won't be able to deploy without your password.

To see all the configured wallets you can call the following: `cast wallet list`.

Clear your history so your private key won't randomly remain there using the following command: `history -c`.

**_Stay safe! Stay froggy! Don't lose your keys. If you are seeing your private key in plain text, you are doing something wrong._**

## Interacting With Contract Addresses via Command Line

cast

## [Chisel](https://getfoundry.sh/chisel/overview#chisel)

Chisel is a fast, utilitarian, and verbose Solidity REPL.

From here, start writing Solidity code! Chisel will offer verbose feedback on each input.

Create a variable a and query it:

```sh
➜ uint256 a = 123;
➜ a
Type: uint256
├ Hex: 0x7b
├ Hex (full word): 0x000000000000000000000000000000000000000000000000000000000000007b
└ Decimal: 123
```

## check gas

```sh
forge snapshot
```

## check smart contract storage layout

```sh
forge inspect FundMe storageLayout
```

## contract layout

// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

## The Checks-Effects-Interactions (CEI) Pattern

The Checks-Effects-Interactions pattern is a `crucial best practice` in `Solidity` development aimed at `enhancing the security` of smart contracts, especially against **`reentrancy attacks`**.

- **Checks**: `Validate inputs` and `conditions` to ensure the function can execute safely. This includes checking permissions, input validity, and contract state prerequisites.

- **Effects**: Modify the state of `our contract` based on the validated inputs. This phase ensures that all internal state changes occur before any external interactions.

- **Interactions**: Perform external calls to other contracts or accounts. This is the last step to prevent reentrancy attacks, where an external call could potentially call back into the original function before it completes, leading to unexpected behavior.

```solidity
function coolFunction() public {
    // Checks
    checkX();
    checkY();

    // Effects
    updateStateM();

    // Interactions
    sendA();
    callB();
}
```
