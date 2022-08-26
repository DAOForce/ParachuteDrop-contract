// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./cores/ERC20.sol";
import "./cores/draft-ERC20Permit.sol";
import "./ERC20VotesComp.sol";
import "./cores/math/SafeCast.sol";
import {CommonStructs} from "./CommonStructs.sol";
import "hardhat/console.sol";



abstract contract ERC20Trackable is ERC20, ERC20Permit, ERC20VotesComp {

    // round index marker for the last executed Airdrop batch round.
    uint16 private roundNumber = 0;


    function getRoundNumber() public view returns(uint16) {
        return roundNumber;
    }


    function incrementRoundNumber() public {
        roundNumber += 1;
    }


    constructor(string memory name) ERC20Permit(name) {
    }


    // key: roundNumber, value: mapping
    mapping(uint16=>mapping(address => CommonStructs.BalanceCommit[])) private _balanceUpdateHistoryMapping;
    /**
    {
        [ round #1 ]: {
            'address 1': [Commit 1, Commit 2, Commit 3, ...],
            'address 2': [Commit 1, Commit 2, Commit 3, ...],
            ...
        },
        [ round #2 ]: {
            'address 1': [Commit 1, Commit 2, Commit 3, ...],
            'address 2': [Commit 1, Commit 2, Commit 3, ...],
            ...
        },
        ...
    }

     */


    function getBalanceCommitHistoryByAddress(uint16 _roundNumber, address _userAddress) public view returns (CommonStructs.BalanceCommit[] memory) {
        return _balanceUpdateHistoryMapping[_roundNumber][_userAddress];
    }


    function addBalanceCommitHistoryByAddress(uint16 _roundNumber, address _userAddress, CommonStructs.BalanceCommit memory newCommit) public {
        _balanceUpdateHistoryMapping[_roundNumber][_userAddress].push(newCommit);
    }
    

    // Override
    function _afterTokenTransfer(address _from, address _to, uint256 _amount)  
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(_from, _to, _amount);

        uint256 senderBalance = _balances[_from];  // balance of the sender after transfer
        uint256 recipientBalance = _balances[_to]; // balance of the recipient after transfer

        _balanceUpdateHistoryMapping[roundNumber][_from].push(CommonStructs.BalanceCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: senderBalance}));
        _balanceUpdateHistoryMapping[roundNumber][_to].push(CommonStructs.BalanceCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: recipientBalance}));
        
    }


    // Override
    function _mint(address _to, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(_to, _amount);
    }


    // Override
    function _burn(address _account, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(_account, _amount);
    }
}