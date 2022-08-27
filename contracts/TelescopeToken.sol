// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./ERC20Trackable.sol";
import "./cores/ERC20.sol";
import "hardhat/console.sol";

// minting 예제
contract TelescopeToken is ERC20Trackable {

    constructor(
        string memory _name,
        string memory _ticker,
        string memory _DAOName,
        string memory _intro,
        string memory _image,
        string memory _link,
        uint256 _initial_supply,
        address _owner
    ) ERC20(
        _name,
        _ticker,
        _DAOName,
        _intro,
        _image,
        _link,
        _owner) ERC20Trackable (_ticker)
    {
        _mint(address(this), _initial_supply * 10 ** uint(decimals()));
    }
}
