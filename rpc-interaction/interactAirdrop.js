const { abi } = require('../abi/airdropABI');
const { addresses, rpcProviderUrl } = require('./utils/deployInfo');
const { varNameToString, sendTransaction } = require('./utils/transactionSender');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.ScheduledAirdrop;

// const privateKey = process.env.CHARLIE_PRIVATE_KEY;  // Charlie
const privateKey = process.env.DAVID_PRIVATE_KEY;  // David

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

/**
 * Contract methods promise
*/

const ROUND = 1;
const ADDRESS = process.env.CHARLIE_ADDRESS;

const getTokenInfoPromise = contract.getTokenInfo();
const getTokenAddressPromise = contract.getTokenAddress();
const getAirdropSnapshotTimestampsPromise = contract.getAirdropSnapshotTimestamps();
const getRoundDurationInDaysPromise = contract.getRoundDurationInDays();
const getNumOfTotalRoundsPromise = contract.getNumOfTotalRounds();
const getAirdropTargetAddressesPromise = contract.getAirdropTargetAddresses();

const getAirdropAmountPerRoundByAddressPromise = contract.getAirdropAmountPerRoundByAddress(ADDRESS);

const getTotalAirdropVolumePerRoundPromise = contract.getTotalAirdropVolumePerRound();

const getCalculatedAirdropAmountPerRoundByAddressPromise = contract.getCalculatedAirdropAmountPerRoundByAddress(ROUND, ADDRESS);

const getInitialBlockNumberByRoundPromise = contract.getInitialBlockNumberByRound(ROUND);

const claimAirdropPromise = contract.claimAirdrop(ROUND);

const initiateAirdropRoundPromise = contract.initiateAirdropRound();

/**
 * Send method call transactions
*/

// sendTransaction(getTokenAddressPromise, varNameToString({ getTokenAddressPromise }));
// sendTransaction(initiateAirdropRoundPromise, varNameToString({ initiateAirdropRoundPromise }));

sendTransaction(getAirdropTargetAddressesPromise, varNameToString({ getAirdropTargetAddressesPromise }));


