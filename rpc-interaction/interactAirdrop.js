const { abi } = require('../abi/airdropABI');
const { addresses, rpcProviderUrl } = require('./deployInfo');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(rpcProviderUrl);

const address = addresses.ScheduledAirdrop;

const privateKey = process.env.CHARLIE_PRIVATE_KEY;  // Charlie

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

// call contract methods
const sendPromise = contract.claimAirdrop(1);

sendPromise.then(function(transaction){
  console.log(transaction);
});