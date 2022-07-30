pragma solidity ^0.8.0;

library CommonStructs {
    // triggered to create BalanceCommit record by token.transfer() / executeAirdropRound() call.
    struct BalanceCommit {
        uint32 blockNumber;
        uint256 balanceAfterCommit;
    }
}
