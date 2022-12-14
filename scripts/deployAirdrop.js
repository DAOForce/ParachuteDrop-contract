const path = require("path");
const { utils } = require("ethers");
const { addresses } = require('../rpc-interaction/utils/deployInfo');


async function main() {

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

// Airdrop Contract
const AirdropContract = await ethers.getContractFactory("ScheduledAirDrop");

const TOKEN_ADDRESS = addresses.DAOForceToken;
const INFOSTORE_ADDRESS = addresses.ContractInfoStore;


AIRDROP_SNAPSHOT_TIMESTAMPS = [
    Math.round(new Date().setMonth(new Date().getMonth() - 3) / 1000),
    Math.round(new Date().setMonth(new Date().getMonth() - 2) / 1000),
    Math.round(new Date().setMonth(new Date().getMonth() - 1) / 1000),
];  // 과거 날짜 데이터
ROUND_DURATION_IN_DAYS = 7000; // TODO: 현실적인 기준으로 변경
NUM_OF_TOTAL_ROUNDS = 5;
AIRDROP_TARGET_ADDRESSES = [
  "0xFd30064F80e8FE31145047e14229cCdf49354d3A",  // Alice
  "0xBcC1B43C9778fED252f0d38eEfA1D1950578bCb5",  // Charlie
  // "0x50CB5825e5EFBDC4b62EB02a745443a06a9e7d41",  // David
  "0x39D95dB2824c069018865824ee6FC0D7639d9359",  // SigridJin
];
AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS = [utils.parseEther("30"), utils.parseEther("50"), utils.parseEther("70")];
TOTAL_AIRDROP_VOLUME_PER_ROUND = utils.parseEther("150");

console.log("input data >>>> Airdrop timestamps: ", AIRDROP_SNAPSHOT_TIMESTAMPS);

const Airdrop = await AirdropContract.deploy(
    TOKEN_ADDRESS,
    AIRDROP_SNAPSHOT_TIMESTAMPS,
    ROUND_DURATION_IN_DAYS,
    NUM_OF_TOTAL_ROUNDS,
    AIRDROP_TARGET_ADDRESSES,
    AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS,
    TOTAL_AIRDROP_VOLUME_PER_ROUND,
    INFOSTORE_ADDRESS
);

console.log('>>> Deployment in progress...')
await Airdrop.deployed();

  console.log("Deployed airdrop address:", Airdrop.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
