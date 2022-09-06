const path = require("path");

async function main() {

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

// Governor Contract
const ContractInfoStoreContract = await ethers.getContractFactory("ContractInfoStore");

const InfoStore = await ContractInfoStoreContract.deploy();

console.log('>>> Deployment in progress...')
await InfoStore.deployed();

  console.log("Deployed InfoStore address:", InfoStore.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
