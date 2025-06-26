// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "@foundry-devops/DevOpsTools.sol";
import {HelperConfig} from "./HelperRaffleConfig.sol";
import {FundMe} from "../src/FundMe.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    // Chainlink VRF mocks value
    uint96 public constant BASE_FEE = 0;
    uint96 public constant GAS_PRICE = 0;
    uint public constant FUND_AMOUNT = 5 ether;

    // LINK/ETH price
    int256 public constant WEI_PER_UNIT_LINK = 100;

    // Chain IDs
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    address public constant FOUNDRY_DEFAULT_SENDER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
}

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}

contract ChainLinkScript is Script, CodeConstants {
    address deployer;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        deployer = helperConfig.getConfig().account;
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256) {
        vm.startBroadcast(deployer);
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        return subscriptionId;
    }

    function fundSubscription(
        uint256 subscriptionId,
        address vrfCoordinator,
        address linkToken
    ) public {
        uint256 FUND_AMOUNT = 5 ether;

        // console.log("Funding subscription: ", subscriptionId);
        // console.log("Using vrfCoordinator: ", vrfCoordinator);
        // console.log("On chainId: ", block.chainid);

        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(deployer);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT * 100
            );
            vm.stopBroadcast();
        } else {
            console.log(LinkToken(linkToken).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(linkToken).balanceOf(address(this)));
            console.log(address(this));

            vm.startBroadcast(deployer);
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function addConsumer(
        address consumer,
        uint256 subscriptionId,
        address vrfCoordinator
    ) public {
        // address consumer = DevOpsTools.get_most_recent_deployment(
        //     "Raffle",
        //     block.chainid
        // );

        console.log("Adding consumer: ", consumer);
        console.log("To vrfCoordinator: ", vrfCoordinator);
        // console.log("Using subscription: ", subscriptionId);
        // console.log("On chainId: ", block.chainid);

        vm.startBroadcast(deployer);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            consumer
        );
        vm.stopBroadcast();
    }
}
