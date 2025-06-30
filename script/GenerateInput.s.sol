// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract GenerateInput is Script {
    string constant FILE_PATH = "script/target/input.json";

    function run() external {
        // Define airdrop data
        string[] memory types = new string[](2);
        types[0] = "address";
        types[1] = "uint";

        uint256 amount = 2500 * 1e18; // Example amount

        address[] memory whitelist = new address[](4);
        whitelist[0] = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
        whitelist[1] = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        whitelist[2] = 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd;
        whitelist[3] = 0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D;

        string memory json = createJSON(types, whitelist, amount);
        vm.writeFile(FILE_PATH, json);
        console.log("Successfully wrote input.json to %s", FILE_PATH);
    }

    function createJSON(
        string[] memory types,
        address[] memory whitelist,
        uint256 amount
    ) internal pure returns (string memory) {
        string memory json = "{";

        // Add types
        json = string.concat(json, '"types": [');
        for (uint i = 0; i < types.length; i++) {
            json = string.concat(json, '"', types[i], '"');
            if (i < types.length - 1) {
                json = string.concat(json, ", ");
            }
        }
        json = string.concat(json, "], ");

        // Add count
        json = string.concat(
            json,
            '"count": ',
            vm.toString(whitelist.length),
            ", "
        );

        // Add values
        json = string.concat(json, '"values": {');
        for (uint i = 0; i < whitelist.length; i++) {
            json = string.concat(
                json,
                '"',
                vm.toString(i),
                '": {',
                '"0": "',
                vm.toString(whitelist[i]),
                '", ',
                '"1": "',
                vm.toString(amount),
                '"}'
            );
            if (i < whitelist.length - 1) {
                json = string.concat(json, ", ");
            }
        }
        json = string.concat(json, "}}");
        return json;
    }
}
