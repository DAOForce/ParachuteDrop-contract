pragma solidity >=0.7.0 <0.9.0;

import {CommonStructs} from "./CommonStructs.sol";

struct GovernanceTokenInfo {
    bool isAirdropContractOpened;
    CommonStructs.TokenInfo tokenInfo;
}

contract ContractInfoStore {
    event NewGovernanceTokenStored(address governanceTokenAddr, string message);
    GovernanceTokenInfo[] GovernanceTokenList;

    function storeNewGovernanceToken(CommonStructs.TokenInfo memory _tokenInfo) public returns (bool) {
        // 1. creating the GovernanceTokenInfo Struct
        GovernanceTokenInfo memory governanceTokenInfo = GovernanceTokenInfo(false, _tokenInfo);

        // 2. push to the list
        GovernanceTokenList.push(governanceTokenInfo);
        emit NewGovernanceTokenStored(_tokenInfo.tokenContractAddress, "New Governance Token was created");

        // 3. return true
        return true;
    }
}
