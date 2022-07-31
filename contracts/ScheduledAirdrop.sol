import "./ERC20Trackable.sol";
import "./CommonStructs.sol";
import "./cores/math/SafeCast.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.0;


contract ScheduledAirDrop {


    uint32 public numOfTotalRounds;
    uint256 public totalAirdropVolumePerRound;

    address[] public airdropTargetAddresses;
    uint64[] public airdropSnapshotTimestamps; // Snapshot & Airdrop execution activation timestamp of each round (in UNIX seconds timestamp)
    
    mapping(uint16=>uint32) public initialBlockNumberByRound;

    ERC20Trackable token;


    constructor(
        address _tokenAddress,
        uint64[] memory _airdropSnapshotTimestamps,
        uint32 _numOfTotalRounds,
        address[] memory _airdropTargetAddresses,
        uint256 _totalAirdropVolumePerRound
    ) public {
        token = ERC20Trackable(_tokenAddress);
        airdropSnapshotTimestamps = _airdropSnapshotTimestamps;
        numOfTotalRounds = _numOfTotalRounds;
        airdropTargetAddresses = _airdropTargetAddresses;
        totalAirdropVolumePerRound = _totalAirdropVolumePerRound;
    }


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


    /** for each round interval,
     * [ Holding Score ] = [ Number of blocks in certain interval ] * [ Number of token holded at each blocknumber ]
     */


    function _min(uint256 _a, uint256 _b) public pure returns (uint256) {
        return (_a >= _b)?_b:_a;
    }


    function _computeAirdropAmounts(address _userAddress, uint16 _roundNumber, uint16 _roundIndex, uint256 _airdropUnitVolume) public returns (uint256) {

        /** Calculation of the amount of the token that the `_userAddress` can receive
         * in Airdrop round #(_roundNumber).
         * 
         * The amount of the token a user can recieve in Airdrop round #(_roundNumber)
         * is determined by the `Holding Score` the user have achieve from the previous Airdrop round interval.
         */

        // Initialization for the Round 1 Airdrop
        if (_roundNumber == 1) {
            uint32 round1InitialBlockNumber = SafeCast.toUint32(block.number);
            initialBlockNumberByRound[1] = round1InitialBlockNumber;
            return _airdropUnitVolume;

        }

        // BalanceCommit History in array
        CommonStructs.BalanceCommit[] memory balanceCommitHistoryOfUser = token.getBalanceCommitHistoryByAddress(_roundNumber - 1, _userAddress);


        // Denominator

        // Calculation of denominator of the `Holding Score ratio`.
        uint32 currentRoundInitialBlockNumber = SafeCast.toUint32(block.number);
        
        uint32 previousRoundInitialBlockNumber = initialBlockNumberByRound[_roundNumber - 1];        

        initialBlockNumberByRound[_roundNumber] = currentRoundInitialBlockNumber;

        // get the total number of blocks generated in the previous Airdrop round interval
        // to calculate `Holding Score`
        uint32 numberOfBlocksFromPreviousRoundInterval = currentRoundInitialBlockNumber - previousRoundInitialBlockNumber;

        // Maximum amount of possible Airdrop volume from the intial to the previous Airdrop round that one could have received
        // if s/he never sold received token.
        uint256 maxCumulativeAirdropVolume = (_roundNumber - 1) * _airdropUnitVolume;
        uint256 maxAchievableHoldingScore = maxCumulativeAirdropVolume * numberOfBlocksFromPreviousRoundInterval;
        

        // Numerator

        // Calculation of numerator of the `Airdrop Holding Score ratio`.
        uint32 _previousCommitBlockNumber = previousRoundInitialBlockNumber;  // Iniitialize
        uint256 _previousCommitBalance = maxCumulativeAirdropVolume; // Initialize
        uint256 totalScoreOfTheRound = 0;  // Holding Score Accumulator for this round.

        // Calculate the `Holding Score` from the BalanceCommits of each user.
        for (uint i = 0; i < balanceCommitHistoryOfUser.length; i++) {
            console.log("/");
            CommonStructs.BalanceCommit memory _balanceCommit = balanceCommitHistoryOfUser[i];
            
            uint32 _commitBlockNumber = _balanceCommit.blockNumber;
            uint32 _blockNumberInterval = _commitBlockNumber - _previousCommitBlockNumber;

            // Cannot get additional `Holding Score` for the exceeding amount compared to the total Airdropped volume for the user address.
            uint256 _currentEpochScore = _min(maxCumulativeAirdropVolume, _previousCommitBalance) * _blockNumberInterval;

            totalScoreOfTheRound += _currentEpochScore;

            // update local variables for the next loop
            _previousCommitBlockNumber = _commitBlockNumber;
            _previousCommitBalance = _balanceCommit.balanceAfterCommit;
        }

        // calculate ratio of (current holding score / maximum possible holding score)
        uint256 airdropScoreRatio = 100 * totalScoreOfTheRound / maxAchievableHoldingScore;

        // calculated (final) Airdrop amount
        uint256 actualAirdropAmount = _airdropUnitVolume * airdropScoreRatio / 100;

        return actualAirdropAmount;
    }

    function executeAirdropRound(address _tokenContractAddress) public payable {
        
        token.incrementRoundNumber();  // (token's airdrop roundNumber) += 1

        // The maximum amount of Airdrop one could receive from this round (with no penalty)
        uint256 airdropUnitVolume = totalAirdropVolumePerRound / airdropTargetAddresses.length;

        token = ERC20Trackable(_tokenContractAddress);
        uint16 roundNumber = token.getRoundNumber();
        uint16 roundIndex = roundNumber - 1;

        require(block.timestamp > airdropSnapshotTimestamps[roundIndex], "Cannot execute this airdrop round yet.");

        // Execute the Airdrop for the addresses in Airdrop whitelist.
        for (uint i = 0; i < airdropTargetAddresses.length; i++) {

            address targetAddress = airdropTargetAddresses[i];

            // Add round-initial snapshot as the last snapshot of the previous round
            // as a marker for calculating `Holding Score`.
            token.addBalanceCommitHistoryByAddress(
                roundNumber - 1,
                targetAddress,
                CommonStructs.BalanceCommit({
                    blockNumber: SafeCast.toUint32(block.number),
                    balanceAfterCommit: token.balanceOf(targetAddress)
            }));

            // compute the amount of Airdrop for this round / for certain user
            uint256 airdropAmountOfUser = _computeAirdropAmounts(targetAddress, roundNumber, roundIndex, airdropUnitVolume);

            // transfer the token
            token.airdropFromContractAccount(targetAddress, airdropAmountOfUser);
        }

    }
}