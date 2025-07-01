// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {YSK} from "src/YSK.sol";

contract DeployYSK is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places

    function run() external returns (YSK) {
        vm.startBroadcast();
        YSK ysk = new YSK(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return ysk;
    }
}
