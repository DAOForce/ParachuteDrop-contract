const { abi } = require('../abi/contractInfoStoreABI');
const { addresses, rpcProviderUrl } = require('./utils/deployInfo');
const { varNameToString, sendTransaction } = require('./utils/transactionSender');

const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.ContractInfoStore;

const privateKey = process.env.DEPLOY_PRIVATE_KEY;  // Charlie

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

/**
 * Contract methods promise
*/
const TOKEN_ADDRESS = addresses.DAOForceToken;
const USER_ADDRESS = process.env.CHARLIE_ADDRESS;

const getAllGovernanceTokenInfoPromise = contract.getAllGovernanceTokenInfo();
const findGovernanceTokenListIdByAddrPromise = contract.findGovernanceTokenListIdByAddr(TOKEN_ADDRESS);
const findAirdropTokenAddressListByUserAddrPromise = contract.findAirdropTokenAddressListByUserAddr(USER_ADDRESS);

/**
 * Send method call transactions
*/
sendTransaction(getAllGovernanceTokenInfoPromise, varNameToString({ getAllGovernanceTokenInfoPromise }));
sendTransaction(findGovernanceTokenListIdByAddrPromise, varNameToString({ findGovernanceTokenListIdByAddrPromise }));
sendTransaction(findAirdropTokenAddressListByUserAddrPromise, varNameToString({ findAirdropTokenAddressListByUserAddrPromise }));