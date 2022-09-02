// SPDX-License-Identifier: CC0-1.0

import "./GovernanceToken.sol";
import "./ERC20Trackable.sol";
import "./CommonStructs.sol";
import "./cores/math/SafeCast.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.0;

// TODO: 모든 라운드 airdrop이 종료되면 Token.round를 0 또는 1로 다시 초기화


contract ScheduledAirDrop {

    address public tokenAddress;

    uint32 public numOfTotalRounds;
    uint32 public roundDurationInDays;
    uint256 public totalAirdropVolumePerRound;

    address[] public airdropTargetAddresses;  // Check: redundant?
    uint64[] public airdropSnapshotTimestamps; // Snapshot & Airdrop execution activation timestamp of each round (in UNIX seconds timestamp)
    
    mapping(uint16=>uint32) public initialBlockNumberByRound;
    mapping(address=>uint256) public addressToAirdropVolumePerRound;

    // key: roundNumber, value: mapping
    mapping(uint16=>mapping(address=>uint256)) private _calculatedAirdropAmountPerRoundByAddress;
    /**
    {
        [ round #1 ]: {
            'address 1': `airdropAmount for address 1 at round #1`,
            'address 2': `airdropAmount for address 2 at round #1`,
            ...
        },
        [ round #2 ]: {
            'address 1': `airdropAmount for address 1 at round #2`,
            'address 2': `airdropAmount for address 2 at round #2`,
            ...
        },
        ...
    } */

    GovernanceToken token;
    // ERC20Trackable token;

    constructor(
        address _tokenAddress,
        uint64[] memory _airdropSnapshotTimestamps,
        uint32 _roundDurationInDays,
        uint32 _numOfTotalRounds,
        address[] memory _airdropTargetAddresses,
        uint256[] memory _airdropAmountsPerRoundByAddress,
        uint256 _totalAirdropVolumePerRound
    ){
        token = GovernanceToken(_tokenAddress);  // Check: how to verify the pre-deployed contract address is correct?
        // token = ERC20Trackable(_tokenAddress);
        tokenAddress = _tokenAddress;

        // Only the owner of the token contract can deploy the airdrop contract
        require(msg.sender == token.getOwner());

        airdropSnapshotTimestamps = _airdropSnapshotTimestamps;
        roundDurationInDays = _roundDurationInDays;
        numOfTotalRounds = _numOfTotalRounds;
        airdropTargetAddresses = _airdropTargetAddresses;
        totalAirdropVolumePerRound = _totalAirdropVolumePerRound;
        
        require(_airdropTargetAddresses.length == _airdropAmountsPerRoundByAddress.length);
        uint256 sumOfTotalAirdropAmountPerRound;
        for (uint256 i = 0; i < _airdropTargetAddresses.length; i++) {
            addressToAirdropVolumePerRound[_airdropTargetAddresses[i]] = _airdropAmountsPerRoundByAddress[i];  // fill in `addressToAirdropVolumePerRound` mapping
            sumOfTotalAirdropAmountPerRound += _airdropAmountsPerRoundByAddress[i];
        }
        require(sumOfTotalAirdropAmountPerRound == _totalAirdropVolumePerRound);  // double-chceck input array
    }

    // Token contract info getter
    function getTokenInfo() public view returns (CommonStructs.TokenInfo memory) {
        CommonStructs.TokenInfo memory _tokenInfo;
        _tokenInfo.totalSupply = token.totalSupply();
        _tokenInfo.name = token.name();
        _tokenInfo.symbol = token.symbol();
        _tokenInfo.DAOName = token.getDAOName();
        _tokenInfo.intro = token.getIntro();
        _tokenInfo.image = token.getImage();
        _tokenInfo.link = token.getLink();
        _tokenInfo.owner = token.getOwner();
        _tokenInfo.tokenContractAddress = tokenAddress;
        return _tokenInfo;
    }

    // Constructor input params info getters
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }

    function getAirdropSnapshotTimestamps() public view returns (uint64[] memory) {
        return airdropSnapshotTimestamps;
    }

    function getRoundDurationInDays() public view returns (uint32) {
        return roundDurationInDays;
    }
    
    function getNumOfTotalRounds() public view returns (uint32) {
        return numOfTotalRounds;
    }

    function getAirdropTargetAddresses() public view returns (address[] memory) {
        return airdropTargetAddresses;
    }

    function getAirdropAmountPerRoundByAddress(address _address) public view returns (uint256) {
        return addressToAirdropVolumePerRound[_address];
    }

    function getTotalAirdropVolumePerRound() public view returns (uint256) {
        return totalAirdropVolumePerRound;
    }

    // Airdrop rounds info getters
    function getCalculatedAirdropAmountPerRoundByAddress(uint16 _round, address _address) public view returns (uint256) {
        // require(msg.sender == _address);  // You can only view your claimmable airdrop amount
        return _calculatedAirdropAmountPerRoundByAddress[_round][_address];
        // TODO: restrict for round index out of range.
    }

    function getInitialBlockNumberByRound(uint16 _round) public view returns (uint32) {
        return initialBlockNumberByRound[_round];
    }


    /** for each round interval,
     * [ Holding Score ] = [ Number of blocks in certain interval ] * [ Number of token holded at each blocknumber ]
     */


    function _min(uint256 _a, uint256 _b) public pure returns (uint256) {
        return (_a >= _b)?_b:_a;
    }

    function _addressInAllowList(address _address) private view returns (bool) {
        if (addressToAirdropVolumePerRound[_address] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function _computeAirdropAmounts(address _userAddress, uint256 _airdropUnitVolume, uint16 _roundNumber) public returns (uint256) {

        /** Calculation of airdrop amount for each token holder.
         *  The amount of the token `_userAddress` can recieve in airdrop round #(_roundNumber)
         *  is determined by the `Holding Score` the user have achieve from the previous airdrop round interval.
         */

        // Initialization for the Round 1 Airdrop (no calculation of the `holding score`.)
        if (_roundNumber == 1) {
            uint32 firstRoundInitialBlockNumber = SafeCast.toUint32(block.number);
            initialBlockNumberByRound[1] = firstRoundInitialBlockNumber;
            return _airdropUnitVolume;
        }

        // BalanceCommit History from the previous round (in BalanceCommit object array)
        CommonStructs.BalanceCommit[] memory balanceCommitHistoryOfUser = token.getBalanceCommitHistoryByAddress(_roundNumber - 1, _userAddress);

        // Denominator

        // Calculation of denominator of the `Holding Score ratio`
        // which is the maximum holding volume one could have achieved.
        uint32 currentRoundInitialBlockNumber = SafeCast.toUint32(block.number);
        uint32 previousRoundInitialBlockNumber = initialBlockNumberByRound[_roundNumber - 1];        

        initialBlockNumberByRound[_roundNumber] = currentRoundInitialBlockNumber;

        // get the total number of blocks generated in the previous Airdrop round interval
        // to calculate `Holding Score`
        uint32 numberOfBlocksFromPreviousRoundInterval = currentRoundInitialBlockNumber - previousRoundInitialBlockNumber;

        // Maximum amount of possible Airdrop volume from the initial to the previous Airdrop round that one could have received
        // if the holder never sold received token.
        uint256 maxCumulativeAirdropVolume = (_roundNumber - 1) * _airdropUnitVolume;
        uint256 maxAchievableHoldingScore = maxCumulativeAirdropVolume * numberOfBlocksFromPreviousRoundInterval;
        

        // Numerator

        // Calculation of numerator of the `Airdrop Holding Score ratio`
        // considering the penalty for token dumping between airdrop rounds.
        uint32 _previousCommitBlockNumber = previousRoundInitialBlockNumber;  // Initialize
        uint256 _previousCommitBalance = maxCumulativeAirdropVolume; // Initialize
        uint256 totalScoreOfTheRound = 0;  // Holding Score Accumulator for this round.

        // Calculate the `Holding Score` from the BalanceCommits of each user.
        for (uint i = 0; i < balanceCommitHistoryOfUser.length; i++) {
            CommonStructs.BalanceCommit memory _balanceCommit = balanceCommitHistoryOfUser[i];  // Balance commit history instance.
            
            uint32 _commitBlockNumber = _balanceCommit.blockNumber;
            uint32 _blockNumberInterval = _commitBlockNumber - _previousCommitBlockNumber;  // Number of blocks between balance commits.

            // Cannot get additional `Holding Score` for the exceeding amount compared to the total Airdropped volume for the user address.
            // `Epoch` stands for the period between two balance commits (recored by token transfer)
            uint256 _currentEpochScore = _min(maxCumulativeAirdropVolume, _previousCommitBalance) * _blockNumberInterval;

            totalScoreOfTheRound += _currentEpochScore;

            // update local variables for the next loop
            _previousCommitBlockNumber = _commitBlockNumber;
            _previousCommitBalance = _balanceCommit.balanceAfterCommit;
        }

        // calculate ratio of (current holding score / maximum possible holding score)
        uint256 airdropScoreRatio = 100 * totalScoreOfTheRound / maxAchievableHoldingScore;

        // calculated (final) Airdrop amount
        // uint256 actualAirdropAmount = _airdropUnitVolume * airdropScoreRatio / 100;
        return _airdropUnitVolume * airdropScoreRatio / 100;
        // return actualAirdropAmount;
    }

    // TODO: to fix the snapshot blocknumber?
    function initiateAirdropRound() public {  // Check: renamed (executeAirdropRound => initiateAirdropRound)

        uint16 roundNumber = token.getRoundNumber();
        // uint16 roundIndex = roundNumber - 1;

        // TODO: 아래에 복붙, 여기서 삭제 검토
        // require(block.timestamp > airdropSnapshotTimestamps[roundIndex], "Cannot execute this airdrop round yet.");

        // Execute the Airdrop for the addresses in Airdrop allowlist.
        
        address[] memory _airdropTargetAddresses = airdropTargetAddresses;
        for (uint i = 0; i < _airdropTargetAddresses.length; i++) {
            address targetAddress = _airdropTargetAddresses[i];
            uint256 airdropUnitVolume = addressToAirdropVolumePerRound[targetAddress];  // The maximum amount of Airdrop `targetAddress` could receive from this round (with no penalty)

            // Add round-openning snapshot as the last snapshot of the previous round
            // as a marker for calculating `Holding Score`.
            token.addBalanceCommitHistoryByAddress(
                roundNumber - 1,  // TODO Check
                targetAddress,
                CommonStructs.BalanceCommit({
                    blockNumber: SafeCast.toUint32(block.number),
                    balanceAfterCommit: token.balanceOf(targetAddress)
            }));

            // compute the amount of Airdrop for this round / for certain user
            // TODO: to charge gas fee for `computeAirdropAmounts` call to claimers?
            // TODO: warning: for loop over dynamic array
            uint256 airdropAmountOfAddress = _computeAirdropAmounts(targetAddress, airdropUnitVolume, roundNumber);

            // update `_calculatedAirdropAmountPerRoundByAddress` mapping with calculated airdrop amounts by holder's addresses.
            _calculatedAirdropAmountPerRoundByAddress[roundNumber][targetAddress] = airdropAmountOfAddress;

            // transfer the token
            // token.airdropFromContractAccount(targetAddress, airdropAmountOfAddress);
        }

        token.incrementRoundNumber();  // increment token's airdrop roundNumber.
    }

    function claimAirdrop(uint16 _roundNumber) public payable {

        require(_addressInAllowList(msg.sender), "You're not in token airdrop allowlist.");  // Check if the function caller is in airdrop allowlist.

        uint16 _roundIndex = _roundNumber - 1;
        require(block.timestamp > airdropSnapshotTimestamps[_roundIndex], "Cannot claim for the airdrop yet.");
        require(block.timestamp <= airdropSnapshotTimestamps[_roundIndex] + roundDurationInDays * 24 * 60 * 60, "Claim period is over for this round");  // TODO: check timestamp calculation
        
        // if문보다 더 괜찮은 구현이 있는가?
        if (_calculatedAirdropAmountPerRoundByAddress[_roundNumber][msg.sender] == 0) {
            initiateAirdropRound();
        }

        uint256 airdropAmount = _calculatedAirdropAmountPerRoundByAddress[_roundNumber][msg.sender];
        
        token.airdropFromContractAccount(msg.sender, airdropAmount);
    }
}
