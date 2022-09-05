const { abi } = require('../abi/abi_token');

var ethers = require('ethers');
var provider = new ethers.providers.JsonRpcProvider("https://ethereum-goerli-rpc.allthatnode.com");

var address  = '0x598a8F9AEBB6693D9763A70a072B997112Ca654e';  // token contract address

var privateKey = process.env.DEPLOY_PRIVATE_KEY;

var wallet = new ethers.Wallet(privateKey,provider);

var contract = new ethers.Contract(address,abi,wallet);

var sendPromise = contract.getRoundNumber();


sendPromise.then(function(transaction){
  console.log(transaction);
});
