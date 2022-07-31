import "./ERC20Trackable.sol";
import "./CommonStructs.sol";
import "./cores/math/SafeCast.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.0;


contract ScheduledAirDrop {
    // address public treasuryCoinbase;
    // uint16 public numberOfAirdropRounds;
    uint32 public numOfTotalRounds;
    uint256 public totalAirdropVolumePerRound;  // 각 라운드 에어드랍 토큰 전체 물량
    address[] public airdropTargetAddresses;  // TODO 라운드별로 가변적인 경우
    uint64[] public airdropSnapshotTimestamps; // 각 라운드 에어드랍 실행 허용 시점(execute)이자 스냅샷 기준시점 (in UNIX timestamp)
    // uint32[] public initialBlockNumberByRound;  // 각 라운드의 시작 시점 블록 넘버
    mapping(uint16=>uint32) public initialBlockNumberByRound;  // 각 라운드의 시작 시점 블록 넘버

    ERC20Trackable token;


    constructor(address _tokenAddress, uint64[] memory _airdropSnapshotTimestamps,
        uint32 _numOfTotalRounds, address[] memory _airdropTargetAddresses,
        uint256 _totalAirdropVolumePerRound
    ) public {

        token = ERC20Trackable(_tokenAddress);
        airdropSnapshotTimestamps = _airdropSnapshotTimestamps;
        numOfTotalRounds = _numOfTotalRounds;
        airdropTargetAddresses = _airdropTargetAddresses;
        totalAirdropVolumePerRound = _totalAirdropVolumePerRound;
    } // TODO: UI에서 입력받은 상태변수 값 초기화 코드 작성

    function getNumOfTotalRounds() public view virtual returns (uint32) {
        return numOfTotalRounds;
    }

    function getTotalAirdropVolumePerRound() public view virtual returns (uint256) {
        return totalAirdropVolumePerRound;
    }

    function getAirdropTargetAddresses() public view virtual returns (address[] memory) {
        return airdropTargetAddresses;
    }

    function getAirdropSnapshotTimestamps() public view virtual returns (uint64[] memory) {
        return airdropSnapshotTimestamps;
    }

    function getInitialBlockNumberByRound(uint16 _round) public view virtual returns (uint32) {
        return initialBlockNumberByRound[_round];
    }

    // 홀딩 스코어 = 해당 기간동안 블록넘버 수 * 각 블록넘버에서 홀드하고 있었던 토큰의 수
    // uint256[] public cumulativeTotalHoldingScore;  // 에어드랍받은 토큰을 한 번도 안 팔고 전부 계속 가지고 있었을 경우의 스코어 누적 값
    // mapping(address=>uint256)[] public cumulativeHoldingScoreByAddress;  // 각 라운드까지 토큰을 홀딩하고 있던 스코어의 누적 값 => 0으로 초기화해야함.
    // mapping(address=>uint256)[] public addressToAirdropAmountArray;  // 인덱스: roundIndex

    function _min(uint256 _a, uint256 _b) public pure returns (uint256) {
        return (_a >= _b)?_b:_a;
    }

    function _computeAirdropAmounts(address _userAddress, uint16 _roundNumber, uint16 _roundIndex, uint256 _airdropUnitVolume) public returns (uint256) {

        // Round 1 (최초) 에어드랍일 경우 airdropScoreRatio = 1로 초기설정
        if (_roundNumber == 1) {
            uint32 round1InitialBlockNumber = SafeCast.toUint32(block.number);
            initialBlockNumberByRound[1] = round1InitialBlockNumber;
            return _airdropUnitVolume;

        }

        // 커밋 구조체 히스토리(배열)
        CommonStructs.BalanceCommit[] memory balanceCommitHistoryOfUser = token.getBalanceCommitHistoryByAddress(_roundNumber - 1, _userAddress);
        console.log("COMMIT HISTORY LIST LENGTH: ", balanceCommitHistoryOfUser.length);


        // 분모 계산
        // 직전 라운드 이후, 현재 라운드까지의 블록넘버 수
        uint32 currentRoundInitialBlockNumber = SafeCast.toUint32(block.number);  // 현재 (에어드랍 시점) 블록넘버
        
        uint32 previousRoundInitialBlockNumber = initialBlockNumberByRound[_roundNumber - 1];        

        initialBlockNumberByRound[_roundNumber] = currentRoundInitialBlockNumber;

        uint32 numberOfBlocksFromPreviousRoundInterval = currentRoundInitialBlockNumber - previousRoundInitialBlockNumber;  // 직전 라운드의 총 블록 넘버 수 (홀딩 스코어 계산을 위함)

        console.log("$$$$$$$$$$$$$$ BLOCK INTERVAL COUNT ", numberOfBlocksFromPreviousRoundInterval);
        // 에어드랍받은 물량을 한 번도 안 팔았을 경우 이전 라운드 인터벌(이전라운드시작~이번라운드시작직전)의 홀딩 스코어
        // 각 라운드에 에어드랍되는 최대 토큰 수는 라운드별로 고정되어있는 조건
        uint256 maxCumulativeAirdropVolume = (_roundNumber - 1) * _airdropUnitVolume;  // 1라운드~직전라운드까지 최대로 에어드랍 받을 수 있었던 토큰의 양
        uint256 maxAchievableHoldingScore = maxCumulativeAirdropVolume * numberOfBlocksFromPreviousRoundInterval;  // 3라운드 에어드랍일 경우, 2라운드에 드롭받은 걸 계속 유지했을 경우 maxScore
        
        // 분자 계산
        uint32 _previousCommitBlockNumber = previousRoundInitialBlockNumber;  // 초기화
        uint256 _previousCommitBalance = maxCumulativeAirdropVolume; // 이전라운드가 끝나는 시점의 스냅샷 balance 값으로 초기화  // TODO 수정
//        CommonStructs.BalanceCommit[] memory previousBalanceCommitHistoryOfUser = token.getBalanceCommitHistoryByAddress(_roundNumber-1, _userAddress);
        uint256 totalScoreOfTheRound = 0;  // Holding Score Accumulator for this round.

        // uint256 _previousCommitBalance = ?
            console.log("############## HISTORY LENGTH ", balanceCommitHistoryOfUser.length);

        for (uint i = 0; i < balanceCommitHistoryOfUser.length; i++) {
            CommonStructs.BalanceCommit memory _balanceCommit = balanceCommitHistoryOfUser[i];
            
            uint32 _commitBlockNumber = _balanceCommit.blockNumber;
            // uint256 _balanceAfterCommit = _balanceCommit.balanceAfterCommit;  // 필요 없음
            uint32 _blockNumberInterval = _commitBlockNumber - _previousCommitBlockNumber;
            console.log(">>>>>>>> MAX CUMUL VOLUME", maxCumulativeAirdropVolume);
            console.log(">>>>>>>> PREV COMMIT BALANCE ", _previousCommitBalance);


            uint256 _currentEpochScore = _min(maxCumulativeAirdropVolume, _previousCommitBalance) * _blockNumberInterval;

            console.log("<<<<<<< CURRENT EPOCH SCORE ", _currentEpochScore);

            totalScoreOfTheRound += _currentEpochScore;



            _previousCommitBlockNumber = _commitBlockNumber;  // 다음 커밋 검사 (for문)을 위해 값 업데이트
            _previousCommitBalance = _balanceCommit.balanceAfterCommit;  // 다음 커밋 검사 (for문)을 위해 값 업데이트
        }
            console.log("############## TOTAL SCORE OF THE ROUND ", totalScoreOfTheRound);


        // 홀딩 스코어 비율 계산
        uint256 airdropScoreRatio = 100 * totalScoreOfTheRound / maxAchievableHoldingScore;
        console.log("@@@@@@@ MAX ACHIEVABLE SCORE", maxAchievableHoldingScore);

        // 실제 에어드랍 양 리턴
        console.log("AIRDROP SCORE RATIO", airdropScoreRatio);
        uint256 actualAirdropAmount = _airdropUnitVolume * airdropScoreRatio / 100;

        // addressToAirdropAmountArray[_roundIndex][_userAddress] = actualAirdropAmount;  // TODO: for문 안에서 compute랑 transfer까지 하려면 이 mapping이 필요없다.
        return actualAirdropAmount;
    }

    function executeAirdropRound(address _tokenContractAddress) public payable {
        token.incrementRoundNumber();  // (token's airdrop roundNumber) += 1

        // TODO: 서명 없이 payable 호출하기: transfer() / payable 키워드 삭제하기?
        // IDEA: EOA 대신 Gnosis multi-sig에 treasury 보관해두기
        // TODO: 각 라운드마다 airdrop 하고 남은 금액은 DAO 지갑으로 넣기

        // 이 함수 call하자마자 스냅샷 찍어서 직전 라운드의 token.addBalanceCommitHistoryByAddress(_roundNumber - 1, _userAddress, newCommit); 해줘야함



        uint256 airdropUnitVolume = totalAirdropVolumePerRound / airdropTargetAddresses.length; // 하나의 user address가 이번 라운드에서 받게 될 토큰의 amount (페널티 적용 전)

        token = ERC20Trackable(_tokenContractAddress);
        uint16 roundNumber = token.getRoundNumber();
        uint16 roundIndex = roundNumber - 1;

        require(block.timestamp > airdropSnapshotTimestamps[roundIndex], "Cannot execute this airdrop round yet.");

        // 에어드랍 대상자 주소 목록을 순회하면서 에어드랍 실행
        for (uint i = 0; i < airdropTargetAddresses.length; i++) {
            console.log("\n\n");

            address targetAddress = airdropTargetAddresses[i];
            // 여기서, 현재 라운드를 시작하는 스냅샷을 직전 라운드의 마지막 스냅샷 커밋으로 추가해준다.
            token.addBalanceCommitHistoryByAddress(
                roundNumber - 1,
                targetAddress,
                CommonStructs.BalanceCommit({
                    blockNumber: SafeCast.toUint32(block.number),
                    balanceAfterCommit: token.balanceOf(targetAddress)
            }));

            uint256 airdropAmountOfUser = _computeAirdropAmounts(targetAddress, roundNumber, roundIndex, airdropUnitVolume);  // 특정 user가 airdrop받을 amount를 계산

            // 토큰 전송
            // token.transferFrom(treasuryCoinbase, targetAddress, addressToAirdropAmountArray[roundIndex][targetAddress]);
            // token.transfer(targetAddress, addressToAirdropAmountArray[roundIndex][targetAddress]);
            console.log("AIRDROP AMOUNT OF USER", airdropAmountOfUser);
//            token.transfer(targetAddress, airdropAmountOfUser);
            token.airdropFromContractAccount(targetAddress, airdropAmountOfUser);



            // 다음 라운드 에어드랍을 위해 모든 계정에 BalanceCommit 추가 (라운드를 넘기면서 일괄 스냅샷 남기기)  // IDEA) airdropFromContractAccount()에서 스냅샷이 생성된다.
            // token.addBalanceCommitHistoryByAddress(
            //     roundNumber,
            //     targetAddress,
            //     CommonStructs.BalanceCommit({
            //         blockNumber: SafeCast.toUint32(block.number),
            //         balanceAfterCommit: token.balanceOf(targetAddress)
            // }));


        }

        // 해당 라운드에 페널티에 의해 차감된 양은 그대로 treasury에 존재함
        // token.incrementRoundNumber();  // (token's airdrop roundNumber) += 1

    }
}