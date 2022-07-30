pragma solidity ^0.8.0;

import "./ERC20Trackable.sol";
import "./cores/ERC20.sol";

// minting 예제
contract TelescopeToken is ERC20Trackable {
    uint256 INITIAL_SUPPLY = 100000;  // 100000 TEL를 발행

    constructor(
        string memory _name, string memory _ticker,
        string memory _DAOName, string memory _intro,
        string memory _image, string memory _link
    ) ERC20(_name, _ticker, _DAOName, _intro, _image, _link) ERC20Trackable (_ticker)
    {
        _mint(msg.sender, INITIAL_SUPPLY * 10 ** uint(decimals()));
    }
}
