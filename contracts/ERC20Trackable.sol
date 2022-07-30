pragma solidity ^0.8.0;

import "./cores/ERC20.sol";
import "./cores/draft-ERC20Permit.sol";
import "./ERC20VotesComp.sol";
import "./cores/math/SafeCast.sol";
import {CommonStructs} from "./CommonStructs.sol";


abstract contract ERC20Trackable is ERC20, ERC20Permit, ERC20VotesComp {

    uint16 public roundNumber = 0;  // 최초 에어드랍 진행 시 roundNumber = 1

    function getRoundNumber() public view returns(uint16) {
        return roundNumber;
    }

    constructor(string memory name) ERC20Permit(name) {}

    mapping(address => CommonStructs.BalanceCommit[]) private _balanceUpdateHistory;

    function getBalanceUpdateHistoryByAddress(address _userAddress) public view returns (CommonStructs.BalanceCommit[] memory) {
        return _balanceUpdateHistory[_userAddress];
    }

    function addBalanceUpdateHistoryByAddress(address _userAddress, CommonStructs.BalanceCommit memory newCommit) public {
        _balanceUpdateHistory[_userAddress].push(newCommit);
    }
    
    function getBalanceCommit(address _userAddress, uint _index) public view returns(uint32, uint256) {
        uint32 _blockNumber = _balanceUpdateHistory[_userAddress][_index].blockNumber;
        uint256 _balanceAfterCommit = _balanceUpdateHistory[_userAddress][_index].balanceAfterCommit;
        return (_blockNumber, _balanceAfterCommit);  // Rename to 'Commit'
    }

    // transfer 이후  trigger하는 hook
    function _afterTokenTransfer(address _from, address _to, uint256 _amount)  
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(_from, _to, _amount);
        // Record balance update commits
        // TODO: Check) mapping에 없던 key에 접근할 수 있는가?

        // ckpts.push(Checkpoint({fromBlock: SafeCast.toUint32(block.number), votes: SafeCast.toUint224(newWeight)}));

        uint256 senderBalance = _balances[_from];  // 업데이트 이후 balance
        uint256 recipientBalance = _balances[_to]; // 업데이트 이후 balance

        _balanceUpdateHistory[_from].push(CommonStructs.BalanceCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: senderBalance}));  // TODO check) afterTransfer 시점에 balance는 업데이트되어있는 상태?
        _balanceUpdateHistory[_to].push(CommonStructs.BalanceCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: recipientBalance}));
        
    }

    function _mint(address _to, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(_to, _amount);
    }

    function _burn(address _account, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(_account, _amount);
    }
}