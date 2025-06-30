// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/MerkleAirdrop.sol";
import "script/MerkleAirdropDeploy.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdropScript public merkleAirdropScript;
    MerkleAirdrop public airdrop;
    address public merkleAirdropAddress;

    address public user;
    uint256 public userPrivKey;
    uint256 public amountToCollect;
    bytes32[] public proof;
    address public gasPayer;
    IERC20 public token;

    function setUp() public {
        merkleAirdropScript = new MerkleAirdropScript();
        merkleAirdropAddress = merkleAirdropScript.run();
        merkleAirdrop = MerkleAirdrop(merkleAirdropAddress);

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function signMessage(
        uint256 privKey,
        address account
    ) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(
            account,
            amountToCollect
        );
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        // get the signature
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
