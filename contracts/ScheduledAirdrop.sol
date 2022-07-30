import "./ERC20Trackable.sol";
import "./CommonStructs.sol";


pragma solidity ^0.8.0;

contract ScheduledAirDrop {
    
    address public treasuryCoinbase;  // TODO: find better representation
    uint16 public numbOfAirdropRounds;
    address[] public airdropTargetAddresses;
    uint64[] public snapShotTimestamps;  // 각 라운드 에어드랍 전 스냅샷 기준 시점
    uint64[] public airdropExecutionTimestamps; // 각 라운드 에어드랍 실행 허용 시점(execute)
    // TODO: airdropExecutionTimestamps.length == N(라운드)인지 검사

    mapping(address=>uint256)[] public addressToAirdropAmountArray;  // 인덱스: roundNumber
    /**
    [
        {
            'userAddress1': 320,
            'userAddress2': 145,
            ...
        },
        {
            'userAddress1': 190,
            'userAddress2': 1450,
            ...
        }
    ]
     */

    // TODO Check) view?
    // for문 안에서 실행됨.
    function _computeAirdropAmounts(address _userAddress, uint16 _roundNumber) public {
        // ERC20Trackable token = ERC20Trackable(_tokenContractAddress);
        CommonStructs.BalanceUpdateCommit[] memory balanceUpdateHistoryOfUser = token._balanceUpdateHistory[_userAddress];
        /**
         * 여기 구현해야함.
         */
    }

    function executeAirdropRound(address _tokenContractAddress, uint16 _roundNumber) public payable returns(bool success) {
        // TODO: 서명 없이 payable 호출하기: transfer()
        // TODO: payable 키워드 삭제
        // IDEA: EOA 대신 Gnosis multi-sig에 treasury 보관해두기

        // require => round 시간
        require(now > airdropExecutionTimestamps[_roundNumber], "nnnn");

        ERC20Trackable token = ERC20Trackable(_tokenContractAddress);

        for(uint i=0; i<airdropTargetAddresses.lenght;i++) {
            address airdropTargetAddress = airdropTargetAddresses[i];
            _computeAirdropAmounts(airdropTargetAddress, _roundNumber);  // user가 airdrop받을 amount를 계산
            // token.transferFrom(treasuryCoinbase, airdropTargetAddress, addressToAirdropAmountArray[_roundNumber][airdropTargetAddress]);
            token.transfer(airdropTargetAddress, addressToAirdropAmountArray[_roundNumber][airdropTargetAddress]);
        }

    }
     
}