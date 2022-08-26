const path = require("path");

async function main() {

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  const DECIMALS = 18;
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Airdrop = await ethers.getContractFactory("ScheduledAirDrop");
  const airdrop = await Airdrop.deploy(
    "0x598a8F9AEBB6693D9763A70a072B997112Ca654e",
    [
        1656920303,
        1656930303,
        1656940303
    ],
    3,
    [
        "0xBcC1B43C9778fED252f0d38eEfA1D1950578bCb5",  // bsc 1
        "0x25BA43364BF720d8dFe3c2680CB4C232a29B093C",  // main
        "0xDe264e2133963c9f40e07f290E1D852f7e4e4c7c"  // extra
    ],
    // 30000 * 10 ** DECIMALS  // 라운드 당 에어드랍 수량
    '30000000000000000000000'  // in string (to deal with BN)
  );

  await airdrop.deployed();

  console.log("Airdrop address:", airdrop.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
