// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

import {DeployGundamNft} from "script/DeployGundamNFT.s.sol";
import {GundamNft} from "src/GundamNft.sol";
// import {MintGundamNft} from "script/Interactions.s.sol";

contract gundamNftTest is Test, ZkSyncChainChecker {
    string constant NFT_NAME = "Gundam";
    string constant NFT_SYMBOL = "GUNDAM";

    GundamNft public gundamNft;
    DeployGundamNft public deployer;
    address public deployerAddress;

    string public constant PUG_URI =
        "bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4";
    address public constant USER = address(1);
    address public owner;

    function setUp() public {
        if (!isZkSyncChain()) {
            deployer = new DeployGundamNft();
            gundamNft = deployer.run();
            owner = gundamNft.owner();
        } else {
            gundamNft = new GundamNft();
        }
    }

    function testInitializedCorrectly() public view {
        // assert(
        //     keccak256(abi.encodePacked(gundamNft.name())) ==
        //         keccak256(abi.encodePacked((NFT_NAME)))
        // );
        // assert(
        //     keccak256(abi.encodePacked(gundamNft.symbol())) ==
        //         keccak256(abi.encodePacked((NFT_SYMBOL)))
        // );
        assertEq(gundamNft.getTokenCounter(), 0);
        assertEq(gundamNft.symbol(), "GUNDAM");
        assertEq(gundamNft.name(), "Gundam");
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(owner);
        gundamNft.mintNft(USER, PUG_URI);
        assert(gundamNft.balanceOf(USER) == 1);
    }

    function testTransfer() public {
        vm.prank(owner);
        gundamNft.mintNft(USER, PUG_URI);
        assert(gundamNft.balanceOf(USER) == 1);

        vm.prank(USER);
        gundamNft.transferFrom(USER, owner, 0);
        assert(gundamNft.balanceOf(owner) == 1);
    }

    // Remember, scripting doesn't work with zksync as of today!
    // function testMintWithScript() public {
    //     uint256 startingTokenCount = gundamNft.getTokenCounter();
    //     MintgundamNft mintgundamNft = new MintgundamNft();
    //     mintgundamNft.mintNftOnContract(address(gundamNft));
    //     assert(gundamNft.getTokenCounter() == startingTokenCount + 1);
    // }

    // can you get the coverage up?
}
