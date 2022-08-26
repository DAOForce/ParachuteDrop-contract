const { abi } = require('../abi/abi_token');

var ethers = require('ethers');
var provider = new ethers.providers.JsonRpcProvider("https://eth.bd.evmos.dev:8545");

var address  = '0x29A4976E8F6D11A4D933e9FBB543c74D6F16387F';  // token contract address

var privateKey = process.env.PRIVATE_KEY_EVMOS;

var wallet = new ethers.Wallet(privateKey,provider);

var contract = new ethers.Contract(address,abi,wallet);

// var sendPromise = contract.setValue('Hello World');
// var sendPromise = contract.name();
// var sendPromise = contract.balanceOf('0xFd30064F80e8FE31145047e14229cCdf49354d3A');
var sendPromise = contract.getRoundNumber();
// var sendPromise = contract.incrementRoundNumber();


sendPromise.then(function(transaction){
  console.log(transaction);
});
