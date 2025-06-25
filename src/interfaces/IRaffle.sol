// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IRaffle {
    /**
     * @dev Error messages
     */
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );
    error Raffle__TransferFailed();
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__RaffleNotOpen();

    /**
     * @dev Enum
     */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    }

    /**
     * @dev events
     */
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed player);
}
