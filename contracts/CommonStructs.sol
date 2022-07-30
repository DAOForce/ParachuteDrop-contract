pragma solidity ^0.8.0;

library CommonStructs {
    struct BalanceCommit {
        uint32 blockNumber;
        uint256 balanceAfterCommit;
    }
}
