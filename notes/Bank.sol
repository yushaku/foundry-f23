pragma solidity 0.8.26;

// Code 1
contract Bank {
    // user => debt
    mapping(address => uint256) public debts;
    // user => timestamp of last borrow
    mapping(address => uint256) public timestamps;
    // timestamp => rates (1 = 1e18)
    mapping(uint256 => uint256) public rates;

    function calculateDebt(address user) external view returns (uint256) {
        uint256 debt = debts[user];
        uint256 k = timestamps[user];
        uint256 n = block.timestamp;

        for (uint256 t = k; t < n; t++) {
            debt = debt * rates[t] / 1e18;
        }

        return debt;
    }
}

// Code 2
contract Bank {
    // user => debt
    mapping(address => uint256) public debts;

    // R(n-1)
    uint256 public cumulativeRates = 1e18;
    // R(k-1)
    // user => cumulative rate when user borrowed
    mapping(address => uint256) public userCumulativeRates;

    function calculateDebt(address user) external view returns (uint256) {
        return debts[user] * cumulativeRates / userCumulativeRates[user];
    }
}

// Code 3
contract Bank {
    // user => debt
    mapping(address => uint256) public debts;

    // R(n-1)
    uint256 public cumulativeRates = 1e18;

    function calculateDebt(address user) external view returns (uint256) {
        return debts[user] * cumulativeRates / 1e18;
    }

    function updateCumulativeRates() public {}

    function borrow(uint256 amount) external {
        updateCumulativeRates();
        debts[msg.sender] += amount * 1e18 / cumulativeRates;
    }

    function repay(uint256 amount) external {
        updateCumulativeRates();
        debts[msg.sender] -= amount * 1e18 / cumulativeRates;
    }
}
