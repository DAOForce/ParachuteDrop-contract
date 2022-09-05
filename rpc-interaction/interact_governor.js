const { abi } = require('../abi/abi_governor');

var ethers = require('ethers');

var provider = new ethers.providers.JsonRpcProvider("https://ethereum-goerli-rpc.allthatnode.com");

var address  = '0x789084347E263B86972bEC32c244aae72A7fB094';

var privateKey = process.env.CHARLIE_PRIVATE_KEY;  // Charlie

var wallet = new ethers.Wallet(privateKey,provider);

var contract = new ethers.Contract(address,abi,wallet);

var sendPromise = contract.claimAirdrop(1);

sendPromise.then(function(transaction){
  console.log(transaction);
});