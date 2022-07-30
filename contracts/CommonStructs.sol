pragma solidity ^0.8.0;

library CommonStructs {
    struct BalanceUpdateCommit {
        uint32 blockNumber;
        uint256 balanceAfterCommit;
    }
}
