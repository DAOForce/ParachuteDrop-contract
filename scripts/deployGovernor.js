const path = require("path");
const { addresses } = require('../rpc-interaction/utils/deployInfo');


async function main() {

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

// Governor Contract
const GovernorContract = await ethers.getContractFactory("DAOForceGovernor");

const TOKEN_ADDRESS = addresses.DAOForceToken;

const Governor = await GovernorContract.deploy(TOKEN_ADDRESS);

console.log('>>> Deployment in progress...')
await Governor.deployed();

  console.log("Deployed Governor address:", Governor.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
