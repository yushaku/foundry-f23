// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {HelperConfig, NetworkConfig} from "./HelperConfig.s.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";

contract DeployMinimal is Script {
  function deployMinimalAccount()
    public
    returns (
      HelperConfig helperConfigInstance,
      MinimalAccount minimalAccountContract
    )
  {
    HelperConfig helperConfig = new HelperConfig();
    NetworkConfig memory config = helperConfig.getConfig();
    vm.startBroadcast(config.account);

    MinimalAccount minimalAccount = new MinimalAccount(
      config.account,
      config.entryPoint
    );

    vm.stopBroadcast();

    return (helperConfig, minimalAccount);
  }

  function run() public returns (HelperConfig, MinimalAccount) {
    return deployMinimalAccount();
  }
}
