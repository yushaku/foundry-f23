// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract MerkleAirdropScript is Script {
    MerkleAirdrop public merkleAirdrop;

    function setUp() public {}

    function run() public returns (address) {
        vm.startBroadcast();

        merkleAirdrop = new MerkleAirdrop();

        vm.stopBroadcast();
        return address(merkleAirdrop);
    }
}
