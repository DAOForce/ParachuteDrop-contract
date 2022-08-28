const { expect } = require("chai");
const { ethers } = require("hardhat");

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage or Hardhat Network's snapshot functionality.
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const {BigNumber} = require("ethers");

// Contructor of Airdrop Contract
// constructor(
//   address _tokenAddress,
//   uint64[] memory _airdropSnapshotTimestamps,
//   uint32 _numOfTotalRounds,
//   address[] memory _airdropTargetAddresses,
//   uint256[] memory _airdropAmountsPerRoundByAddress,
//   uint256 _totalAirdropVolumePerRound
// )

// Airdrop Contract constructor data
let TOKEN_ADDRESS;
let AIRDROP_SNAPSHOT_TIMESTAMPS;
let ROUND_DURATION_IN_DAYS;
let NUM_OF_TOTAL_ROUNDS;
// allowlist input data
let AIRDROP_TARGET_ADDRESSES;
let AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS;
let TOTAL_AIRDROP_VOLUME_PER_ROUND;

describe("Token Contract", function() {
    async function deployTokenFixture() {

        // Signers
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();

        // Token Contract
        const Token = await ethers.getContractFactory("TelescopeToken");

        const TelescopeToken = await Token.deploy(
            "TelescopeToken",
            "TELE",
            "TelescopeDAO",
            "DAO for interstellar telescope launch",
            "some_image_url",
            "some_website_link",
            1500,  // DECIMAL == 18
            owner.getAddress()
        );
        await TelescopeToken.deployed();

        // Airdrop Contract
        const Airdrop = await ethers.getContractFactory("ScheduledAirDrop");
        
        TOKEN_ADDRESS = TelescopeToken.address;
        AIRDROP_SNAPSHOT_TIMESTAMPS = [
            Math.round(new Date().setMonth(new Date().getMonth() - 3) / 1000),
            Math.round(new Date().setMonth(new Date().getMonth() - 2) / 1000),
            Math.round(new Date().setMonth(new Date().getMonth() - 1) / 1000),
        ];  // 과거 날짜 데이터
        ROUND_DURATION_IN_DAYS = 7;
        NUM_OF_TOTAL_ROUNDS = 5;
        AIRDROP_TARGET_ADDRESSES = [addr1.address, addr2.address, addr3.address];
        AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS = [30, 50, 70];  // Check: decimal?
        TOTAL_AIRDROP_VOLUME_PER_ROUND = 30 + 50 + 70;

        console.log("input data >>>> Airdrop timestamps: ", AIRDROP_SNAPSHOT_TIMESTAMPS);

        const TelescopeTokenAirdrop = await Airdrop.deploy(
            TOKEN_ADDRESS,
            AIRDROP_SNAPSHOT_TIMESTAMPS,
            ROUND_DURATION_IN_DAYS,
            NUM_OF_TOTAL_ROUNDS,
            AIRDROP_TARGET_ADDRESSES,
            AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS,
            TOTAL_AIRDROP_VOLUME_PER_ROUND
        );

        return { Token, TelescopeToken, Airdrop, TelescopeTokenAirdrop, owner, addr1, addr2, addr3};
    }

    describe("Token Deployment", function() {
        it("Should assign the total supply of tokens to the contract address", async function() {
            const {TelescopeToken, owner} = await loadFixture(deployTokenFixture);
            const contractBalance = await TelescopeToken.balanceOf(TelescopeToken.address);
            expect(await TelescopeToken.totalSupply()).to.equal(contractBalance);
            console.log("input data >>>> total token supply: ", await TelescopeToken.totalSupply());

        });
    })
})