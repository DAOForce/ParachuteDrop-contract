const { abi } = require('../abi/abi_airdrop');
const { contractAddresses } = require('./deployInfo');
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider("https://ethereum-goerli-rpc.allthatnode.com");

const address  = '0x430A560069d148f08a760c6272606DdE77bAAF69';

const privateKey = process.env.CHARLIE_PRIVATE_KEY;  // Charlie

const wallet = new ethers.Wallet(privateKey,provider);

const contract = new ethers.Contract(address,abi,wallet);

const sendPromise = contract.claimAirdrop(1);

sendPromise.then(function(transaction){
  console.log(transaction);
});