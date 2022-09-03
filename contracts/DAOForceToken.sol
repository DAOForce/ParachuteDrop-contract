// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./ERC20/ERC20Trackable.sol";
import "hardhat/console.sol";


// DAO governance token deployment & mint token to the token contract itself
contract DAOForceToken is ERC20Trackable {
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _DAOName,
        string memory _intro,
        string memory _image,
        string memory _link,
        address _owner,
        uint256 _initial_supply
    )  ERC20Trackable (
        _name,
        _symbol,
        _DAOName,
        _intro,
        _image,
        _link,
        _owner)
    {
        _mint(address(this), _initial_supply * 10 ** uint(decimals()));
    }
}