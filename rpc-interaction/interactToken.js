const { abi } = require('../abi/tokenABI');
const { addresses, rpcProviderUrl } = require('./deployInfo');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.DAOForceToken;

const privateKey = process.env.DEPLOY_PRIVATE_KEY;

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

/**
 * Contract methods promise
*/

const ROUND = 1;
const ADDRESS = process.env.CHARLIE_ADDRESS;

// ERC20 getters
const totalSupplyPromise = contract.totalSupply();
const balanceOfPromise = contract.balanceOf(ADDRESS);

// ERC20Votes getters
const POS = 1;
const BLOCKNUMBER = 100000;

const checkpointsPromise = contract.checkpoints(ADDRESS, POS);
const numCheckpointsPromise = contract.numCheckpoints(ADDRESS);
const delegatesPromise = contract.delegates(ADDRESS);
const getVotesPromise = contract.getVotes(ADDRESS);
const getPastVotesPromise = contract.getPastVotes(ADDRESS, BLOCKNUMBER);
const getPastTotalSupplyPromise = contract.getPastTotalSupply(BLOCKNUMBER);

// ERC20Trackable getters
const getDAONamePromise = contract.getDAOName();
const getIntroPromise = contract.getIntro();
const getImagePromise = contract.getImage();
const getLinkPromise = contract.getLink();
const getOwnerPromise = contract.getOwner();
const getRoundNumberPromise = contract.getRoundNumber();
const getBalanceCommitHistoryByAddressPromise = contract.getBalanceCommitHistoryByAddress(ROUND, ADDRESS);
