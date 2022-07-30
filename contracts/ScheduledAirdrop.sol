import "./ERC20Trackable.sol";
import "./CommonStructs.sol";
import "./cores/math/SafeCast.sol";


pragma solidity ^0.8.0;

contract ScheduledAirDrop {

    address public treasuryCoinbase;  // TODO: find better representation
    uint16 public numberOfAirdropRounds;
    uint256 public totalAirdropVolumePerRound;  // 각 라운드 에어드랍 기준 토큰 수(100% 기준, address 하나당)
    address[] public airdropTargetAddresses;
    uint64[] public snapShotTimestamps;  // 각 라운드 에어드랍 전 스냅샷 기준 시점
    uint32[] public initialBlockNumberByRound;
    uint64[] public airdropExecutionTimestamps; // 각 라운드 에어드랍 실행 허용 시점(execute)
    ERC20Trackable token;

    // TODO: airdropExecutionTimestamps.length == N(라운드)인지 검사

    // 홀딩 스코어 = 해당 기간동안 블록넘버 수 * 각 블록넘버에서 홀드하고 있었던 토큰의 수
    uint256[] public cumulativeTotalHoldingScore;  // 에어드랍받은 토큰을 한 번도 안 팔고 전부 계속 가지고 있었을 경우의 스코어 누적 값
    mapping(address=>uint256)[] public cumulativeHoldingScoreByAddress;  // 각 라운드까지 토큰을 홀딩하고 있던 스코어의 누적 값 => 0으로 초기화해야함.
    mapping(address=>uint256)[] public addressToAirdropAmountArray;  // 인덱스: roundIndex

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

    // for문 안에서 실행
    // 해당 userAddress가 특정 Round에서 에어드랍받게될 토큰의 양을 계산하고 mapping을 업데이트한다.
    // 분모: 첫 라운드부터 직전 라운드까지 airdropUnitVolume의 합 (ex. 1라운드: 100, 2라운드: 200, ...) => 상수 (누적되므로)
    // 분자: 첫 라운드부터 직전 라운드까지 그래프 면적 - 미달된 면적 => cumulativeHoldingScoreByAddress[_userAddress] + 이번 홀딩 스코어 계산 로직
    // 이번 홀딩 스코어 계산 로직: _balanceUpdateHistoryArray[_roundIndex][_userAddress] Array for문으로 돌면서 홀딩 스코어 계산
    // 홀딩 스코어 볼륨 계산하는 법:
    //      0. 먼저 해당 라운드에 해당 사용자가 몇 번의 Commit을 일으켰는지 참조한다.
    //      0.1. Commit 리스트를 순회 (for문)
    //      1. 각 라운드의 Initial Commit 때의 balance를 참조한다.
    //      2. Commit들 사이의 블록넘버 수를 계산해서, 곱하여 면적을 구한다.
    //      
    // 이후 cumulativeHoldingScoreByAddress 업데이트
    // userAddress가 받게 될 양 = airdropUnitVolume * (분자 / 분모)

    function _min(uint256 _a, uint256 _b) public pure returns (uint256) {
        return (_a >= _b)?_b:_a;
    }

    function _computeAirdropAmounts(address _userAddress, uint16 _roundNumber, uint16 _roundIndex, uint256 _airdropUnitVolume) public returns (uint256) {

        // 커밋 구조체 히스토리(배열)
        CommonStructs.BalanceCommit[] memory balanceCommitHistoryOfUser = token.getBalanceCommitHistoryByAddress(_roundIndex, _userAddress);
        

        // 분모 계산
        // 직전 라운드 이후, 현재 라운드까지의 블록넘버 수
        uint32 currentRoundInitialBlockNumber = SafeCast.toUint32(block.number);  // 현재 (에어드랍 시점) 블록넘버
        uint32 previousRoundInitialBlockNumber = initialBlockNumberByRound[_roundIndex - 1];  // TODO: _roundIndex인지, _roundNumber인지 점검하기 (초기 세팅 확인)
        initialBlockNumberByRound.push(currentRoundInitialBlockNumber);

        uint32 numberOfBlocksFromPreviousRoundInterval = currentRoundInitialBlockNumber - previousRoundInitialBlockNumber;  // 직전 라운드의 총 블록 넘버 수

        // 에어드랍받은 물량을 한 번도 안 팔았을 경우 이전 라운드 인터벌(이전라운드시작~이번라운드시작직전)의 홀딩 스코어
        // 각 라운드에 에어드랍되는 최대 토큰 수는 라운드별로 고정되어있는 조건
        uint256 maxHoldingScore = (_roundNumber - 1) * _airdropUnitVolume * numberOfBlocksFromPreviousRoundInterval;  // 3라운드 에어드랍일 경우, 2라운드에 드롭받은 걸 계속 유지했을 경우 maxScore
        

        // 분자 계산
        uint256 previousRoundMaxAirdropVolume = (_roundNumber - 1) * _airdropUnitVolume;  // 이전 라운드에서 아무런 페널티 없이 100% 에어드랍 받았을 경우 받은 양
        uint32 _previousCommitBlockNumber = previousRoundInitialBlockNumber;  // 초기화
        uint256 _previousCommitBalance = previousRoundMaxAirdropVolume; // 초기화

        uint256 totalScoreOfTheRound = 0;  // 이게 스코어(분자) 카운터

        // uint256 _previousCommitBalance = ?
        for (uint i = 0; i < balanceCommitHistoryOfUser.length; i++) {
            CommonStructs.BalanceCommit memory _balanceCommit = balanceCommitHistoryOfUser[i];
            
            uint32 _commitBlockNumber = _balanceCommit.blockNumber;
            // uint256 _balanceAfterCommit = _balanceCommit.balanceAfterCommit;  // 필요 없음
            uint32 _blockNumberInterval = _commitBlockNumber - _previousCommitBlockNumber;

            uint256 _currentEpochScore = _min(previousRoundMaxAirdropVolume, _previousCommitBalance) * _blockNumberInterval;

            totalScoreOfTheRound += _currentEpochScore;

            _previousCommitBlockNumber = _commitBlockNumber;  // 다음 커밋 검사 (for문)을 위해 값 업데이트
            _previousCommitBalance = _balanceCommit.balanceAfterCommit;  // 다음 커밋 검사 (for문)을 위해 값 업데이트
        }

        // 비율 계산

        uint256 airdropScoreRatio = totalScoreOfTheRound / maxHoldingScore;

        // 실제 에어드랍 양 리턴
        uint256 actualAirdropAmount = _airdropUnitVolume * airdropScoreRatio;

        addressToAirdropAmountArray[_roundIndex][_userAddress] = actualAirdropAmount;  // TODO: for문 안에서 compute랑 transfer까지 하려면 이 mapping이 필요없다.

        return actualAirdropAmount;
    }

    function executeAirdropRound(address _tokenContractAddress) public payable returns(bool success) {
        // TODO: 서명 없이 payable 호출하기: transfer()
        // TODO: payable 키워드 삭제
        // IDEA: EOA 대신 Gnosis multi-sig에 treasury 보관해두기
        // TODO: 각 라운드마다 airdrop 하고 남은 금액은 DAO 지갑으로 넣기

        // require => round 시간

        uint256 airdropUnitVolume = totalAirdropVolumePerRound / airdropTargetAddresses.length; // 가중치가 1인 address가 한 번의 라운드에서 받게 될 토큰의 amount
        // uint256 numberOfBlocksInInterval

        token = ERC20Trackable(_tokenContractAddress);
        uint16 roundNumber = token.getRoundNumber();
        uint16 roundIndex = roundNumber - 1;
        require(block.timestamp > airdropExecutionTimestamps[roundIndex], "Cannot execute the airdrop yet.");


        for (uint i = 0; i < airdropTargetAddresses.length; i++) {

            address targetAddress = airdropTargetAddresses[i];

            // TODO: 주석 해제
            uint256 airdropAmountOfUser = _computeAirdropAmounts(targetAddress, roundNumber, roundIndex, airdropUnitVolume);  // 특정 user가 airdrop받을 amount를 계산

            // 토큰 전송
            // token.transferFrom(treasuryCoinbase, targetAddress, addressToAirdropAmountArray[roundIndex][targetAddress]);
            // token.transfer(targetAddress, addressToAirdropAmountArray[roundIndex][targetAddress]);
            token.transfer(targetAddress, airdropAmountOfUser);

            // 다음 라운드 에어드랍을 위해 모든 계정에 BalanceCommit 추가
            token.addBalanceCommitHistoryByAddress(
                roundIndex,
                targetAddress,
                CommonStructs.BalanceCommit({
                    blockNumber: SafeCast.toUint32(block.number),
                    balanceAfterCommit: token.balanceOf(targetAddress)
            }));

        }

        

    }
     
}