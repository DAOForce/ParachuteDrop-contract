// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");
const { addresses } = require('../rpc-interaction/utils/deployInfo');


async function main() {
  // This is just a convenience check
  // if (network.name === "hardhat") {
  //   console.warn(
  //     "You are trying to deploy a contract to the Hardhat Network, which" +
  //       "gets automatically created and destroyed every time. Use the Hardhat" +
  //       " option '--network localhost'"
  //   );
  // }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log('>>>>> Signers list: ', await ethers.getSigners());
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Token Contract
  const TokenContract = await ethers.getContractFactory("DAOForceToken");

  const INFOSTORE_ADDRESS = addresses.ContractInfoStore;
  
  // Token instance
  const Token = await TokenContract.deploy(
      "JunhaDAOToken",
      "JUNHA",
      "JunhaDAO",
      "DAO for junha.",
      "https://ipfs.io/ipfs/bafybeie4lxug2vxod3clrb3krv5e2bbrmpexjgdzdfqkewbkc5egol3nmu/ef_image_white.png",
      "some_website_link",
      1500,  // DECIMAL == 18
      INFOSTORE_ADDRESS
  );
  console.log('>>> Deployment in progress...')
  await Token.deployed();

  console.log("Deployed Token address:", Token.address);

  // We also save the contract's artifacts and address in the frontend directory
  // saveFrontendFiles(token);
}

// function saveFrontendFiles(token) {
//   const fs = require("fs");
//   const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

//   if (!fs.existsSync(contractsDir)) {
//     fs.mkdirSync(contractsDir);
//   }

//   fs.writeFileSync(
//     path.join(contractsDir, "contract-address.json"),
//     JSON.stringify({ Token: token.address }, undefined, 2)
//   );

//   const TokenArtifact = artifacts.readArtifactSync("TelescopeToken");

//   fs.writeFileSync(
//     path.join(contractsDir, "Token.json"),
//     JSON.stringify(TokenArtifact, null, 2)
//   );
// }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
