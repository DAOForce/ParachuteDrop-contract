// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "hardhat/console.sol";

import {CommonStructs} from "../common/CommonStructs.sol";
import "../ContractInfoStore.sol";


contract ERC20Trackable is ERC20, ERC20Permit, ERC20Votes {

    ContractInfoStore contractInfoStore;

    // round index marker for the last executed Airdrop batch round.
    uint16 private roundNumber = 1;  // TODO: Initialize to Zero?

    string private _DAOName; // DAO name
    string private _intro; // DAO short introduction
    string private _image; // DAO profile image url link
    string private _link; // DAO webpage url link
    address private _owner; // Contract owner

    constructor(
        string memory _name,
        string memory _symbol,
        string memory DAOName,
        string memory intro,
        string memory image,
        string memory link,
        uint256 _initial_supply,
        address mintedERC20ContractAddr,
        // address contractInfoStoreAddr
        ContractInfoStore _contractInfoStoreAddress
    ) ERC20 (_name, _symbol) ERC20Permit(_name) {
        _DAOName = DAOName;
        _intro = intro;
        _image = image;
        _link = link;
        _owner = msg.sender;

        CommonStructs.TokenInfo memory _tokenInfo = CommonStructs.TokenInfo(
            _initial_supply * 10 ** uint(decimals()),
            _name,
            _symbol,
            DAOName,
            intro,
            image,
            link,
            _owner,
            mintedERC20ContractAddr
        );

        contractInfoStore = _contractInfoStoreAddress;
        // contractInfoStore = ContractInfoStore(contractInfoStoreAddr);
        contractInfoStore.storeNewGovernanceToken(_tokenInfo);
    }

    function getTokenName() public view returns (string memory) {
        return name();
    }

    function getTicker() public view returns (string memory) {
        return symbol();
    }

    function getDAOName() public view returns (string memory) {
        return _DAOName;
    }

    function getIntro() public view returns (string memory) {
        return _intro;
    }

    function getImage() public view returns (string memory) {
        return _image;
    }

    function getLink() public view returns (string memory) {
        return _link;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getRoundNumber() public view returns(uint16) {
        return roundNumber;
    }


    function incrementRoundNumber() public {
        roundNumber += 1;
    }


    // constructor(string memory name) ERC20Permit(name) {
    // }


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
    } */


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

        uint256 senderBalance = balanceOf(_from);  // balance of the sender after transfer
        uint256 recipientBalance = balanceOf(_to);  // balance of the recipient after transfer

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


    function airdropFromContractAccount(address to, uint256 amount) public returns (bool) {
        address tokenContract = address(this);
        _transfer(tokenContract, to, amount);
        return true;
    }
}