// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperRaffleConfig.sol";
import {console} from "forge-std/console.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {
        (Raffle raffle, ) = deployContract();
        console.log("Raffle contract deployed to: ", address(raffle));
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig networkConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = networkConfig.getConfig();

        if (config.subscriptionId == 0) {
            // deploy subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, ) = createSubscription.run();
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.subscriptionId,
            config.gasLane,
            config.interval,
            config.entranceFee,
            config.callbackGasLimit,
            config.vrfCoordinator
        );
        vm.stopBroadcast();

        return (raffle, networkConfig);
    }
}
