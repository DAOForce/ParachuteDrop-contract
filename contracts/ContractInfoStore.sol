pragma solidity >=0.7.0 <0.9.0;

import {CommonStructs} from "./CommonStructs.sol";
import "hardhat/console.sol";

struct GovernanceTokenInfo {
    bool isAirdropContractOpened;
    address airdropTokenAddress;
    CommonStructs.TokenInfo tokenInfo;
    address[] airdropTargetAddressList;
}

contract ContractInfoStore {
    event NewGovernanceTokenStored(address governanceTokenAddr, string message);
    GovernanceTokenInfo[] GovernanceTokenList;

    function storeNewGovernanceToken(CommonStructs.TokenInfo memory _tokenInfo) public returns (bool) {
        // 1. creating the GovernanceTokenInfo Struct
        GovernanceTokenInfo memory governanceTokenInfo = GovernanceTokenInfo(false, 0x0000000000000000000000000000000000000000, _tokenInfo, new address[](0));

        // 2. push to the list
        GovernanceTokenList.push(governanceTokenInfo);
        emit NewGovernanceTokenStored(_tokenInfo.tokenContractAddress, "New Governance Token was created");

        // 3. return true
        return true;
    }

    function getAllGovernanceTokenInfo() public view returns (GovernanceTokenInfo[] memory) {
        return GovernanceTokenList;
    }

    function findGovernanceTokenListIdByAddr(address governanceTokenAddr) public view returns (uint){
        for (uint i = 0; i < GovernanceTokenList.length; i++) {
            if (GovernanceTokenList[i].tokenInfo.tokenContractAddress == governanceTokenAddr) {
                console.log(" FOUND TOKEN ADDR >>>>>>>>>>>>>>>>>>>>>> ", GovernanceTokenList[i].tokenInfo.tokenContractAddress);
                return i;
            }
        }
        revert("Not Found Governance Token");
    }

    function addAirdropTokenAddress(address governanceTokenAddr, address airdropTokenAddr, address[] calldata _airdropTargetAddresses) public returns (bool) {
        uint foundGovTokenId = findGovernanceTokenListIdByAddr(governanceTokenAddr);
        GovernanceTokenList[foundGovTokenId].isAirdropContractOpened = true;
        GovernanceTokenList[foundGovTokenId].airdropTokenAddress = airdropTokenAddr;
        GovernanceTokenList[foundGovTokenId].airdropTargetAddressList = _airdropTargetAddresses;
        return true;
    }
}
