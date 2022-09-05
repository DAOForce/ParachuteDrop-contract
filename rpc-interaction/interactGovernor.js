const { abi } = require('../abi/governorABI');
const { addresses, rpcProviderUrl } = require('./deployInfo');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.DAOForceGovernor;

const privateKey = process.env.DEPLOY_PRIVATE_KEY;  // Charlie

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

// call contract methods


sendPromise.then(function(transaction){
  console.log(transaction);
});