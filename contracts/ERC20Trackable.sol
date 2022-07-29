pragma solidity ^0.8.0;

import "./cores/ERC20.sol";
import "./cores/draft-ERC20Permit.sol";
import "./ERC20VotesComp.sol";


abstract contract ERC20Trackable is ERC20, ERC20Permit, ERC20VotesComp {

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}