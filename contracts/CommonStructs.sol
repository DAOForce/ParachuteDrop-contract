pragma solidity ^0.8.0;

library CommonStructs {
    // BalanceCommit snapshot record
    // triggered by token._transfer() / executeAirdropRound() call.
    struct BalanceCommit {
        uint32 blockNumber;
        uint256 balanceAfterCommit;
    }
}
