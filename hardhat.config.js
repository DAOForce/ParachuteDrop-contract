require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");


// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // defaultNetwork: "evmos",
  solidity: "0.8.9",
  networks: {
    evmos: {
      url: "https://eth.bd.evmos.dev:8545",
      accounts: [process.env.DEPLOY_PRIVATE_KEY],
      // gas: 210000000,
      // gasPrice: 8000000000,
      // gas: "auto",
      // gasPrice: "auto",
    },
    evmos_mainnet: {
      url: "https://eth.bd.evmos.org:8545",
      accounts: [process.env.DEPLOY_PRIVATE_KEY],
    },
    goerli: {
      url: "https://ethereum-goerli-rpc.allthatnode.com",
      accounts: [process.env.DEPLOY_PRIVATE_KEY]
    }
  }
};
