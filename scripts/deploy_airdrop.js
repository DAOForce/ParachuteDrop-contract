const path = require("path");

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

TOKEN_ADDRESS = Token.address;  // TODO: 토큰 배포 후 주입하기 (command line params?)
AIRDROP_SNAPSHOT_TIMESTAMPS = [
    Math.round(new Date().setMonth(new Date().getMonth() - 3) / 1000),
    Math.round(new Date().setMonth(new Date().getMonth() - 2) / 1000),
    Math.round(new Date().setMonth(new Date().getMonth() - 1) / 1000),
];  // 과거 날짜 데이터
ROUND_DURATION_IN_DAYS = 7000; // TODO: 현실적인 기준으로 변경
NUM_OF_TOTAL_ROUNDS = 5;
AIRDROP_TARGET_ADDRESSES = [addr1.address, addr2.address, addr3.address];
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
    TOTAL_AIRDROP_VOLUME_PER_ROUND
);

await Airdrop.deployed();

  console.log("Airdrop address:", airdrop.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
