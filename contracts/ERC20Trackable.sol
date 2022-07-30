pragma solidity ^0.8.0;

import "./cores/ERC20.sol";
import "./cores/draft-ERC20Permit.sol";
import "./ERC20VotesComp.sol";
import "./cores/math/SafeCast.sol";
import "./CommonStructs.sol";


abstract contract ERC20Trackable is ERC20, ERC20Permit, ERC20VotesComp {


    mapping(address => CommonStructs.BalanceUpdateCommit[]) internal _balanceUpdateHistory;  // TODO: 접근 제어자 지정 (public?) or/ getter view 함수 지정

    // TODO : web3 JSON-RPC API가 struct를 출력 못하는 이슈 있음
    // function getBalanceUpdateHistory(address userAddress, uint index) public view returns(CommonStructs.BalanceUpdateCommit memory) {

    //     return _balanceUpdateHistory[userAddress][index];  // Rename to 'Commit'
    // }
    
    function getBalanceUpdateCommit(address _userAddress, uint _index) public view returns(uint32, uint256) {
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

        _balanceUpdateHistory[_from].push(CommonStructs.BalanceUpdateCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: senderBalance}));  // TODO check) afterTransfer 시점에 balance는 업데이트되어있는 상태?
        _balanceUpdateHistory[_to].push(CommonStructs.BalanceUpdateCommit({blockNumber: SafeCast.toUint32(block.number), balanceAfterCommit: recipientBalance}));
        
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