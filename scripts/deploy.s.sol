// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {RebaseToken} from "contracts/RebaseToken.sol";
import {Vault} from "contracts/Vault.sol";
// import {Helper} from "scripts/helper.s.sol";

contract Deploy {
    function run() public returns (RebaseToken, Vault) {
        RebaseToken rebaseToken = new RebaseToken();
        Vault vault = new Vault(address(rebaseToken));

        rebaseToken.grantRole(rebaseToken.MINT_AND_BURN_ROLE(), address(vault));

        return (rebaseToken, vault);
    }
}
