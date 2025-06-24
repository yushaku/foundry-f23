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
