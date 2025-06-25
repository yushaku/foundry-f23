// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Raffle} from "../src/Raffle.sol";

abstract contract CodeConstants {
    // Chainlink VRF mocks value
    uint96 public constant BASE_FEE = 0.25 ether;
    uint96 public constant GAS_PRICE = 0.25 ether;

    // LINK/ETH price
    int256 public constant WEI_PER_UNIT_LINK = 100;

    // Chain IDs
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is Script, CodeConstants {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
    }

    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether, // 1e16
                interval: 30, // 30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                callbackGasLimit: 500000, // 500,000 gas
                subscriptionId: 0
            });
    }

    function getOrCreateAnvilEthConfig()
        internal
        returns (NetworkConfig memory)
    {
        if (networkConfigs[LOCAL_CHAIN_ID].vrfCoordinator != address(0)) {
            return networkConfigs[LOCAL_CHAIN_ID];
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2_5Mock(
                BASE_FEE,
                GAS_PRICE,
                WEI_PER_UNIT_LINK
            );
        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.01 ether, // 1e16
                interval: 30, // 30 seconds
                vrfCoordinator: address(vrfCoordinatorV2Mock),
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // does not matter
                callbackGasLimit: 500000, // 500,000 gas
                subscriptionId: 0
            });
    }
}
