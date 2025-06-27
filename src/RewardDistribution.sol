// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

import {IRewardDistribution} from "./interfaces/IRewardDistribution.sol";

contract RewardDistribution is IRewardDistribution, Ownable, Multicall {
    using SafeERC20 for IERC20;
    address public constant NATIVE_TOKEN = address(0);

    uint256 private s_epoch;
    mapping(uint256 => mapping(address => bool)) private s_hasClaimed; // epoch => account => claimed
    mapping(uint256 => Reward) private s_epochMerkleRoot; // epoch => merkle root
    mapping(address => bool) private s_tokenWhitelist; // token => whitelisted
    address[] private s_tokens;

    constructor(address _usdc) Ownable(msg.sender) {
        if (_usdc == address(0)) revert RD__ZeroAddress();
        s_tokenWhitelist[_usdc] = true;
        s_tokenWhitelist[NATIVE_TOKEN] = true;
    }

    receive() external payable {
        emit RD__Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit RD__Received(msg.sender, msg.value);
    }

    /*****************************************************************************/
    /** @notice Owner functions */
    /*****************************************************************************/

    function addMerkleRoot(
        bytes32 _merkleRoot,
        address _token
    ) external onlyOwner {
        if (!s_tokenWhitelist[_token]) revert RD__InvalidToken();

        s_epoch++;
        s_epochMerkleRoot[s_epoch] = Reward({
            token: _token,
            merkleRoot: _merkleRoot
        });
        emit RD__MerkleRootAdded(s_epoch, _merkleRoot, _token);
    }

    function updateMerkleRoot(
        bytes32 _merkleRoot,
        address _token
    ) external onlyOwner {
        if (!s_tokenWhitelist[_token]) revert RD__InvalidToken();
        if (s_epochMerkleRoot[s_epoch].merkleRoot == 0)
            revert RD__InvalidMerkleRoot();

        s_epochMerkleRoot[s_epoch] = Reward({
            token: _token,
            merkleRoot: _merkleRoot
        });
        emit RD__MerkleRootUpdated(s_epoch, _merkleRoot, _token);
    }

    function addToken(address _token) external onlyOwner {
        if (_token == address(0)) revert RD__ZeroAddress();
        s_tokenWhitelist[_token] = true;
        s_tokens.push(_token);
        emit RD__TokenWhitelisted(_token);
    }

    function removeToken(address _token) external onlyOwner {
        if (_token == address(0)) revert RD__ZeroAddress();
        delete s_tokenWhitelist[_token];

        uint256 len = s_tokens.length;
        for (uint256 i = 0; i < len; i++) {
            if (s_tokens[i] == _token) {
                s_tokens[i] = s_tokens[len - 1];
                s_tokens.pop();
                break;
            }
        }

        emit RD__TokenRemoved(_token);
    }

    /*****************************************************************************/
    /** @notice User functions */
    /*****************************************************************************/

    function deposit(address token, uint256 amount) external payable {
        if (!s_tokenWhitelist[token]) revert RD__InvalidToken();
        _takeToken(msg.sender, token, amount);
        emit RD__RewardAdded(token, amount);
    }

    function claim(
        uint256 epoch,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (s_hasClaimed[epoch][msg.sender]) revert RD__RewardAlreadyClaimed();

        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount));
        if (
            !MerkleProof.verify(
                merkleProof,
                s_epochMerkleRoot[s_epoch].merkleRoot,
                node
            )
        ) {
            revert RD__InvalidProof();
        }

        s_hasClaimed[epoch][msg.sender] = true;
        _sendToken(msg.sender, s_epochMerkleRoot[epoch].token, amount);

        emit RD__RewardClaimed(msg.sender, amount);
    }

    function isEligible(
        uint256 epoch,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external view returns (bool) {
        if (s_hasClaimed[epoch][account]) return false;

        bytes32 node = keccak256(abi.encodePacked(account, amount));
        return
            MerkleProof.verify(
                merkleProof,
                s_epochMerkleRoot[s_epoch].merkleRoot,
                node
            );
    }

    /*****************************************************************************/
    /** @notice internal functions                                              */
    /*****************************************************************************/

    function _sendToken(address _to, address _token, uint256 _amount) internal {
        if (_token == NATIVE_TOKEN) {
            if (address(this).balance < _amount)
                revert RD__InsufficientBalance();
            (bool success, ) = _to.call{value: _amount}("");
            require(success, "Transfer failed");
        } else {
            IERC20 token = IERC20(_token);
            token.safeTransfer(_to, _amount);
        }
    }

    function _takeToken(
        address _from,
        address _token,
        uint256 _amount
    ) internal {
        if (_token == NATIVE_TOKEN) {
            if (msg.value < _amount) revert RD__InsufficientBalance();
        } else {
            IERC20 token = IERC20(_token);
            token.safeTransferFrom(_from, address(this), _amount);
        }
    }

    /*****************************************************************************/
    /** @notice View functions */
    /*****************************************************************************/

    function currentEpoch() external view returns (uint256) {
        return s_epoch;
    }

    function merkleRoot(uint256 _epoch) external view returns (Reward memory) {
        return s_epochMerkleRoot[_epoch];
    }

    function hasClaimed(
        uint256 _epoch,
        address account
    ) external view returns (bool) {
        return s_hasClaimed[_epoch][account];
    }

    function isWhiteListed(address _token) external view returns (bool) {
        return s_tokenWhitelist[_token];
    }

    function whiteListTokens() external view returns (address[] memory) {
        return s_tokens;
    }
}
