// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {TokenPool} from "@chainlink/contracts-ccip/contracts/pools/TokenPool.sol";
import {Pool} from "@chainlink/contracts-ccip/contracts/libraries/Pool.sol";

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract RebaseTokenPool is TokenPool {
    constructor(
        address _token,
        address[] memory _allowlist,
        address _rnmProxy,
        address _router
    ) TokenPool(IERC20(_token), 18, _allowlist, _rnmProxy, _router) {}

    function lockOrBurn(
        Pool.LockOrBurnInV1 calldata burnIn
    ) external returns (Pool.LockOrBurnOutV1 memory) {
        _validateLockOrBurn(burnIn);

        uint256 interestRate = IRebaseToken(address(i_token))
            .getUserInterestRate(burnIn.originalSender);

        IRebaseToken(address(i_token)).burn(address(this), burnIn.amount);

        return
            Pool.LockOrBurnOutV1({
                destTokenAddress: getRemoteToken(burnIn.remoteChainSelector),
                destPoolData: abi.encode(interestRate)
            });
    }

    function releaseOrMint(
        Pool.ReleaseOrMintInV1 calldata mintIn
    ) external returns (Pool.ReleaseOrMintOutV1 memory) {
        _validateReleaseOrMint(mintIn);

        uint256 interestRate = abi.decode(mintIn.sourcePoolData, (uint256));

        IRebaseToken(address(i_token)).mint(
            address(this),
            mintIn.amount,
            interestRate
        );

        return Pool.ReleaseOrMintOutV1({destinationAmount: mintIn.amount});
    }
}
