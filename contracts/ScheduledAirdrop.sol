import "./ERC20Trackable.sol";
import "./CommonStructs.sol";
import "./cores/math/SafeCast.sol";


pragma solidity ^0.8.0;

contract ScheduledAirDrop {

    address public treasuryCoinbase;  // TODO: find better representation
    uint16 public numberOfAirdropRounds;
    address[] public airdropTargetAddresses;
    uint64[] public snapShotTimestamps;  // 각 라운드 에어드랍 전 스냅샷 기준 시점
    uint64[] public airdropExecutionTimestamps; // 각 라운드 에어드랍 실행 허용 시점(execute)
    ERC20Trackable token;

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
        CommonStructs.BalanceCommit[] memory balanceUpdateHistoryOfUser = token.getBalanceUpdateHistoryByAddress(_userAddress);
        /**
         * 여기 구현해야함.
         */
    }

    function executeAirdropRound(address _tokenContractAddress) public payable returns(bool success) {
        // TODO: 서명 없이 payable 호출하기: transfer()
        // TODO: payable 키워드 삭제
        // IDEA: EOA 대신 Gnosis multi-sig에 treasury 보관해두기
        // TODO: 각 라운드마다 airdrop 하고 남은 금액은 DAO 지갑으로 넣기

        // require => round 시간
        token = ERC20Trackable(_tokenContractAddress);
        uint16 roundNumber = token.getRoundNumber();
        uint16 roundIndex = roundNumber - 1;
        require(block.timestamp > airdropExecutionTimestamps[roundIndex], "Cannot airdrop yet.");


        for (uint i = 0; i < airdropTargetAddresses.length; i++) {

            address targetAddress = airdropTargetAddresses[i];

            _computeAirdropAmounts(targetAddress, roundNumber);  // 특정 user가 airdrop받을 amount를 계산

            // 다음 라운드 에어드랍을 위해 모든 계정에 BalanceCommit 추가
            token.addBalanceUpdateHistoryByAddress(targetAddress, CommonStructs.BalanceCommit({
                blockNumber: SafeCast.toUint32(block.number),
                balanceAfterCommit: token.balanceOf(targetAddress)
            }));

            // token.transferFrom(treasuryCoinbase, targetAddress, addressToAirdropAmountArray[token.roundNumber][targetAddress]);
            token.transfer(targetAddress, addressToAirdropAmountArray[roundIndex][targetAddress]);
        }

        

    }
     
}