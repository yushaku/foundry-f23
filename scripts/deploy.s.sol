// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {RebaseToken, IRebaseToken} from "contracts/RebaseToken.sol";
import {Vault} from "contracts/Vault.sol";
import {RebaseTokenPool} from "contracts/RBPool.sol";
import {RegistryModuleOwnerCustom} from "@chainlink/contracts-ccip/contracts/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@chainlink/contracts-ccip/contracts/tokenAdminRegistry/TokenAdminRegistry.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

contract TokenAndPoolDeployer is Script {
    function run() public returns (RebaseToken token, RebaseTokenPool pool) {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork
            .getNetworkDetails(block.chainid);

        vm.startBroadcast();
        token = new RebaseToken();
        pool = new RebaseTokenPool(
            address(token),
            new address[](0),
            networkDetails.rmnProxyAddress,
            networkDetails.routerAddress
        );

        token.grantRole(token.MINT_AND_BURN_ROLE(), address(pool));
        RegistryModuleOwnerCustom(
            networkDetails.registryModuleOwnerCustomAddress
        ).registerAdminViaOwner(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress)
            .acceptAdminRole(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(
            address(token),
            address(pool)
        );
        vm.stopBroadcast();
    }
}

contract VaultDeployer is Script {
    function run(address _rebaseToken) public returns (Vault vault) {
        vm.startBroadcast();
        vault = new Vault(_rebaseToken);
        bytes32 mintAndBurnRole = IRebaseToken(_rebaseToken)
            .MINT_AND_BURN_ROLE();

        IAccessControl(_rebaseToken).grantRole(mintAndBurnRole, address(vault));
        vm.stopBroadcast();
    }
}
