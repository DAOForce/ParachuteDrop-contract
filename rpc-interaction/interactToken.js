const { abi } = require('../abi/tokenABI');
const { contractAddresses, rpcProviderUrl } = require('./deployInfo');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = contractAddresses.DAOForceToken;

const privateKey = process.env.DEPLOY_PRIVATE_KEY;

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

const sendPromise = contract.getRoundNumber();


sendPromise.then(function(transaction){
  console.log(transaction);
});
