const { abi } = require('../abi/abi_airdrop');

var ethers = require('ethers');
// var provider = ethers.providers.getDefaultProvider('ropsten');
var provider = new ethers.providers.JsonRpcProvider("https://ethereum-goerli-rpc.allthatnode.com");

var address  = '0x430A560069d148f08a760c6272606DdE77bAAF69';

// var privateKey = process.env.PRIVATE_KEY_EVMOS;
var privateKey = "2ba7c3257675a627c8ffca3a37e3cfd504dac101275c6ebc6f1993c9d81ff069";  // Charlie

var wallet = new ethers.Wallet(privateKey,provider);

var contract = new ethers.Contract(address,abi,wallet);

// var sendPromise = contract.setValue('Hello World');
// var sendPromise = contract.name();
// var sendPromise = contract.balanceOf('0xFd30064F80e8FE31145047e14229cCdf49354d3A');
// var sendPromise = contract.getNumOfTotalRounds();
var sendPromise = contract.claimAirdrop(1);

sendPromise.then(function(transaction){
  console.log(transaction);
});