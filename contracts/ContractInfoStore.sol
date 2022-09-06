// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import {CommonStructs} from "./common/CommonStructs.sol";
import "hardhat/console.sol";

struct GovernanceTokenInfo {
    bool isAirdropContractOpened;
    address airdropTokenAddress;
    CommonStructs.TokenInfo tokenInfo;
    address[] airdropTargetAddressList;
}

struct MatchedGovAirdropTokenDTO {
    address airdropTokenAddress;
    address governanceTokenAddress;
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

    function findAirdropTokenAddressListByUserAddr(address userTokenAddr) public view returns (MatchedGovAirdropTokenDTO[] memory) {
        GovernanceTokenInfo[] memory governanceTokenInfoList = getAllGovernanceTokenInfo();
        uint allTokenAmounts = governanceTokenInfoList.length;

        MatchedGovAirdropTokenDTO[] memory matchedGovAirdropTokenDTOList = new MatchedGovAirdropTokenDTO[](allTokenAmounts);
        address[] memory matchedAirdropTokenAddressList = new address[](allTokenAmounts);
        address[] memory matchedGovernanceTokenAddressList = new address[](allTokenAmounts);

        for (uint i = 0; i < governanceTokenInfoList.length; i++) {
            GovernanceTokenInfo memory nowGovernanceTokenInfo = governanceTokenInfoList[i];
            address[] memory nowAirdropAddressList = nowGovernanceTokenInfo.airdropTargetAddressList;
            for (uint j = 0; j < nowAirdropAddressList.length; j++) {
                if (nowAirdropAddressList[j] == userTokenAddr) {
                    matchedAirdropTokenAddressList[i] = nowGovernanceTokenInfo.airdropTokenAddress;
                    matchedGovernanceTokenAddressList[i] = nowGovernanceTokenInfo.tokenInfo.tokenContractAddress;
                    console.log("matchedAirdropTokenAddressList", matchedAirdropTokenAddressList[i]);
                    break;
                }
            }
        }

        for (uint k = 0; k < matchedAirdropTokenAddressList.length; k++) {
            matchedGovAirdropTokenDTOList[k] = MatchedGovAirdropTokenDTO(matchedAirdropTokenAddressList[k], matchedGovernanceTokenAddressList[k]);
        }

        return matchedGovAirdropTokenDTOList;
    }
}
