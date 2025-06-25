pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperRaffleConfig.sol";
import {Raffle} from "src/Raffle.sol";
import {IRaffle} from "src/interfaces/IRaffle.sol";

contract RaffleTest is Test, IRaffle {
    uint256 public constant INIT_BALANCE = 1 ether;

    DeployRaffle public deployRaffle;
    HelperConfig public networkConfig;
    Raffle public raffle;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffle, networkConfig) = deployRaffle.deployContract();

        HelperConfig.NetworkConfig memory config = networkConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;

        vm.deal(alice, INIT_BALANCE);
        vm.deal(bob, INIT_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assertEq(
            uint256(raffle.getRaffleState()),
            uint256(IRaffle.RaffleState.OPEN)
        );
    }

    // enter raffle
    function testRaffleRevertWhenNotEnoughEth() public {
        vm.prank(alice);
        vm.expectRevert(IRaffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle{value: 0}();
    }

    function testRaffleRecordsPlayersWhenEnterRaffle() public {
        vm.prank(alice);
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getPlayer(0), alice);
    }

    function testEnteringRaffleEmitEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnter(alice);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        vm.prank(alice);

        raffle.enterRaffle{value: entranceFee}();

        // warp: set block timestamp
        vm.warp(block.timestamp + interval + 1);

        // roll: set block number
        vm.roll(block.number + 1);

        raffle.performUpkeep("0x0");

        vm.expectRevert(IRaffle.Raffle__RaffleNotOpen.selector);
        vm.prank(bob);
        raffle.enterRaffle{value: entranceFee}();
    }
}
