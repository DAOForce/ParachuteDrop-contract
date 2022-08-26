const { abi } = require('../abi/abi_airdrop');

var ethers = require('ethers');
// var provider = ethers.providers.getDefaultProvider('ropsten');
var provider = new ethers.providers.JsonRpcProvider("https://eth.bd.evmos.dev:8545");

var address  = '0xaf4b8Ccc651600Bd6CfC2C6013e9Df9139F054c6';

var privateKey = process.env.PRIVATE_KEY_EVMOS;

var wallet = new ethers.Wallet(privateKey,provider);

var contract = new ethers.Contract(address,abi,wallet);

// var sendPromise = contract.setValue('Hello World');
// var sendPromise = contract.name();
// var sendPromise = contract.balanceOf('0xFd30064F80e8FE31145047e14229cCdf49354d3A');
// var sendPromise = contract.getNumOfTotalRounds();
var sendPromise = contract.executeAirdropRound('0x598a8F9AEBB6693D9763A70a072B997112Ca654e');

sendPromise.then(function(transaction){
  console.log(transaction);
});