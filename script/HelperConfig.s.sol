// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {EntryPoint} from "@account-abstraction/core/EntryPoint.sol";

struct NetworkConfig {
  address entryPoint;
  address account;
}

contract HelperConfig is Script {
  uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
  uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
  uint256 constant LOCAL_CHAIN_ID = 31337;

  NetworkConfig public activeNetworkConfig;
  address constant BURNER_WALLET = 0x4aBfCf64bB323CC8B65e2E69F2221B14943C6EE1;
  uint256 constant ANVIL_DEFAULT_PRIVATE_KEY =
    0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

  constructor() {
    if (block.chainid == LOCAL_CHAIN_ID) {
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    } else if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
      activeNetworkConfig = getEthSepoliaConfig();
    } else if (block.chainid == ZKSYNC_SEPOLIA_CHAIN_ID) {
      activeNetworkConfig = getZkSyncSepoliaConfig();
    }
  }

  function getConfig() public view returns (NetworkConfig memory) {
    return activeNetworkConfig;
  }

  function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
    return
      NetworkConfig({
        entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
        account: BURNER_WALLET
      });
  }

  function getZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
    // ZKSync Era has native account abstraction; an external EntryPoint might not be used in the same way.
    // address(0) is used as a placeholder or to indicate reliance on native mechanisms.
    return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
  }

  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
    if (activeNetworkConfig.account != address(0)) {
      return activeNetworkConfig;
    }

    vm.startBroadcast(ANVIL_DEFAULT_PRIVATE_KEY);
    EntryPoint entryPoint = new EntryPoint();
    vm.stopBroadcast();

    return
      NetworkConfig({entryPoint: address(entryPoint), account: BURNER_WALLET});
  }
}
