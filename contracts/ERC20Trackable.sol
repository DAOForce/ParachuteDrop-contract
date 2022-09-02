// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./cores/ERC20.sol";
import "./ERC20Votes.sol";
import "./cores/math/SafeCast.sol";
import {CommonStructs} from "./CommonStructs.sol";
import "hardhat/console.sol";


// TODO: inherit ERC20Votes
// contract ERC20Trackable is ERC20, ERC20Votes {
contract ERC20Trackable is ERC20 {

    // round index marker for the last executed Airdrop batch round.
    uint16 private roundNumber = 1;  // TOOD: 0으로 초기화?

    string private _DAOName; // 다오 이름
    string private _intro; // 소개글
    string private _image; // 프로필 이미지
    string private _link; // 링크
    address private _owner; // 컨트랙트 소유자

    constructor(
        string memory _name,
        string memory _symbol,
        string memory DAOName,
        string memory intro,
        string memory image,
        string memory link,
        address owner
    ) ERC20 (_name, _symbol) {
        _DAOName = DAOName;
        _intro = intro;
        _image = image;
        _link = link;
        _owner = owner;
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
        // override(ERC20, ERC20Votes)
        override(ERC20)
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
        // override(ERC20, ERC20Votes)
        override(ERC20)
    {
        super._mint(_to, _amount);
    }


    // Override
    function _burn(address _account, uint256 _amount)
        internal
        // override(ERC20, ERC20Votes)
        override(ERC20)
    {
        super._burn(_account, _amount);
    }


    function airdropFromContractAccount(address to, uint256 amount) public returns (bool) {
        address tokenContract = address(this);
        _transfer(tokenContract, to, amount);
        return true;
    }
}



