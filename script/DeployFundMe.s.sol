// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfigFundMe.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        // real network transactions
        vm.startBroadcast();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        console.log("FundMe contract address: ", address(fundMe));

        vm.stopBroadcast();

        return fundMe;
    }
}
