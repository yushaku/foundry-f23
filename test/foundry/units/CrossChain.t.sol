// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenPool} from "@chainlink/contracts-ccip/contracts/pools/TokenPool.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {RegistryModuleOwnerCustom} from "@chainlink/contracts-ccip/contracts/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@chainlink/contracts-ccip/contracts/tokenAdminRegistry/TokenAdminRegistry.sol";
import {RateLimiter} from "@chainlink/contracts-ccip/contracts/libraries/RateLimiter.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";

import {Vault} from "contracts/Vault.sol";
import {RebaseTokenPool} from "contracts/RBPool.sol";
import {RebaseToken} from "contracts/RebaseToken.sol";
import {IRebaseToken} from "contracts/interfaces/IRebaseToken.sol";

contract CrossChainTest is Test {
    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    Register.NetworkDetails sepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    CCIPLocalSimulatorFork ccip;

    RebaseToken sepoliaToken;
    RebaseToken arbToken;

    Vault sepoliaVault;
    Vault arbVault;

    RebaseTokenPool sepoliaPool;
    RebaseTokenPool arbPool;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        sepoliaFork = vm.createSelectFork("sepolia");
        arbSepoliaFork = vm.createFork("arb-sepolia");

        ccip = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccip));

        // 1. Deploy sepoliaToken
        vm.selectFork(sepoliaFork);
        sepoliaNetworkDetails = ccip.getNetworkDetails(block.chainid);

        vm.startPrank(owner);
        sepoliaToken = new RebaseToken();
        sepoliaVault = new Vault(address(sepoliaToken));
        sepoliaPool = new RebaseTokenPool(
            address(sepoliaToken),
            new address[](0),
            sepoliaNetworkDetails.rmnProxyAddress,
            sepoliaNetworkDetails.routerAddress
        );
        bytes32 mintAndBurnRole = keccak256("MINT_AND_BURN_ROLE");
        sepoliaToken.grantRole(mintAndBurnRole, address(sepoliaVault));
        sepoliaToken.grantRole(mintAndBurnRole, address(sepoliaPool));

        RegistryModuleOwnerCustom(
            sepoliaNetworkDetails.registryModuleOwnerCustomAddress
        ).registerAdminViaOwner(address(sepoliaToken));

        TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress)
            .acceptAdminRole(address(sepoliaToken));

        TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress)
            .setPool(address(sepoliaToken), address(sepoliaPool));

        configureTokenPool(
            sepoliaFork, // Local chain: Sepolia
            address(sepoliaPool), // Local pool: Sepolia's TokenPool
            arbSepoliaNetworkDetails.chainSelector, // Remote chain selector: Arbitrum Sepolia's
            address(arbPool), // Remote pool address: Arbitrum Sepolia's TokenPool
            address(arbToken) // Remote token address: Arbitrum Sepolia's Token
        );
        vm.stopPrank();

        // 2. Deploy arbitrum
        vm.selectFork(arbSepoliaFork);
        arbSepoliaNetworkDetails = ccip.getNetworkDetails(block.chainid);

        vm.startPrank(owner);
        arbToken = new RebaseToken();
        arbVault = new Vault(address(arbToken));
        arbPool = new RebaseTokenPool(
            address(arbToken),
            new address[](0),
            arbSepoliaNetworkDetails.rmnProxyAddress,
            arbSepoliaNetworkDetails.routerAddress
        );
        arbToken.grantRole(mintAndBurnRole, address(arbVault));
        arbToken.grantRole(mintAndBurnRole, address(arbPool));

        RegistryModuleOwnerCustom(
            arbSepoliaNetworkDetails.registryModuleOwnerCustomAddress
        ).registerAdminViaOwner(address(arbToken));

        TokenAdminRegistry(arbSepoliaNetworkDetails.tokenAdminRegistryAddress)
            .acceptAdminRole(address(arbToken));
        vm.stopPrank();

        configureTokenPool(
            arbSepoliaFork, // Local chain: Arbitrum Sepolia
            address(arbPool), // Local pool: Arbitrum Sepolia's TokenPool
            sepoliaNetworkDetails.chainSelector, // Remote chain selector: Sepolia's
            address(sepoliaPool), // Remote pool address: Sepolia's TokenPool
            address(sepoliaToken) // Remote token address: Sepolia's Token
        );
    }

    function configureTokenPool(
        uint256 forkId, // The fork ID of the local chain
        address localPoolAddress, // Address of the pool being configured
        uint64 remoteChainSelector, // Chain selector of the remote chain
        address remotePoolAddress, // Address of the pool on the remote chain
        address remoteTokenAddress // Address of the token on the remote chain
    ) public {
        // 1. Select the correct fork (local chain context)
        vm.selectFork(forkId);

        // 2. Prepare arguments for applyChainUpdates
        // An empty array as we are only adding, not removing.
        uint64[] memory remoteChainSelectorsToRemove = new uint64[](0);

        // Construct the chainsToAdd array (with one ChainUpdate struct)
        TokenPool.ChainUpdate[]
            memory chainsToAdd = new TokenPool.ChainUpdate[](1);

        // The remote pool address needs to be ABI-encoded as bytes.
        // CCIP expects an array of remote pool addresses, even if there's just one primary.
        bytes[] memory remotePoolAddressesBytesArray = new bytes[](1);
        remotePoolAddressesBytesArray[0] = abi.encode(remotePoolAddress);

        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            remotePoolAddresses: remotePoolAddressesBytesArray,
            remoteTokenAddress: abi.encode(remoteTokenAddress),
            outboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: false,
                capacity: 0,
                rate: 0
            }),
            inboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: false,
                capacity: 0,
                rate: 0
            })
        });

        // 3. Execute applyChainUpdates as the owner
        // applyChainUpdates is typically an owner-restricted function.
        vm.prank(owner); // The 'owner' variable should be the deployer/owner of the localPoolAddress
        TokenPool(localPoolAddress).applyChainUpdates(
            remoteChainSelectorsToRemove,
            chainsToAdd
        );
    }

    function bridgeTokens(
        uint256 amountToBridge,
        uint256 localFork,
        uint256 remoteFork,
        Register.NetworkDetails memory localNetworkDetails,
        Register.NetworkDetails memory remoteNetworkDetails,
        RebaseToken localToken,
        RebaseToken remoteToken
    ) public {
        vm.selectFork(localFork);

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: address(localToken),
            amount: amountToBridge
        });

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(user),
            data: "",
            tokenAmounts: tokenAmounts,
            feeToken: localNetworkDetails.linkAddress,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0}))
        });

        uint256 fee = IRouterClient(localNetworkDetails.routerAddress).getFee(
            remoteNetworkDetails.chainSelector,
            message
        );

        // Fund the user with LINK
        ccip.requestLinkFromFaucet(user, fee);

        vm.startPrank(user);
        IERC20(localNetworkDetails.linkAddress).approve(
            localNetworkDetails.routerAddress,
            fee
        );

        IERC20(address(localToken)).approve(
            localNetworkDetails.routerAddress,
            amountToBridge
        );

        uint256 localBalanceBefore = localToken.balanceOf(user);

        IRouterClient(localNetworkDetails.routerAddress).ccipSend(
            remoteNetworkDetails.chainSelector,
            message
        );
        vm.stopPrank();

        uint256 localBalanceAfter = localToken.balanceOf(user);
        assertEq(
            localBalanceAfter,
            localBalanceBefore - amountToBridge,
            "Local balance incorrect after send"
        );

        vm.selectFork(remoteFork);
        vm.warp(block.timestamp + 20 minutes);
        uint256 remoteBalanceBefore = remoteToken.balanceOf(user);

        //Process the message on the remote chain (using CCIPLocalSimulatorFork)
        ccip.switchChainAndRouteMessage(remoteFork);

        uint256 remoteBalanceAfter = remoteToken.balanceOf(user);
        assertEq(
            remoteBalanceAfter,
            remoteBalanceBefore + amountToBridge,
            "Remote balance incorrect after receive"
        );
    }
}
