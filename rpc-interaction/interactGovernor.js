const { abi } = require('../abi/governorABI');
const { addresses, rpcProviderUrl } = require('./utils/deployInfo');
const { varNameToString, sendTransaction } = require('./utils/transactionSender');

const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.DAOForceGovernor;

const privateKey = process.env.DEPLOY_PRIVATE_KEY;  // Charlie

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

/**
 * Contract methods promise
*/


/**
 * Send method call transactions
*/