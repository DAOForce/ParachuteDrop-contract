pragma solidity ^0.8.0;

import "./ERC20Trackable.sol";
import "./cores/ERC20.sol";

// minting 예제
contract TelescopeToken is ERC20Trackable {
    uint256 INITIAL_SUPPLY = 100000;  // 100000 TEL를 발행

    constructor() ERC20("TelescopeToken", "TEL") ERC20Trackable ("TEL") {
        _mint(msg.sender, INITIAL_SUPPLY * 10**uint(decimals()));
    }
}
