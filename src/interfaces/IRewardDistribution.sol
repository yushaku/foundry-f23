// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRewardDistribution {
    /*****************************************************************************/
    /** @notice errors */
    /*****************************************************************************/

    error RD__InsufficientBalance();
    error RD__InvalidProof();
    error RD__InvalidToken();
    error RD__InvalidMerkleRoot();
    error RD__ZeroAddress();
    error RD__RewardAlreadyClaimed();

    /*****************************************************************************/
    /** @notice events */
    /*****************************************************************************/

    event RD__RewardClaimed(address indexed account, uint256 amount);
    event RD__RewardAdded(address indexed token, uint256 amount);
    event RD__MerkleRootAdded(
        uint256 indexed epoch,
        bytes32 merkleRoot,
        address token
    );
    event RD__MerkleRootUpdated(
        uint256 indexed epoch,
        bytes32 merkleRoot,
        address token
    );
    event RD__TokenWhitelisted(address indexed token);
    event RD__TokenRemoved(address indexed token);
    event RD__Received(address indexed from, uint256 amount);

    /*****************************************************************************/
    /** @notice structs */
    /*****************************************************************************/

    struct Reward {
        address token;
        bytes32 merkleRoot;
    }
}
