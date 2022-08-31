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
        const TokenContract = await ethers.getContractFactory("GovernanceToken");

        // Token instance
        const Token = await TokenContract.deploy(
            "TelescopeToken",
            "TELE",
            "TelescopeDAO",
            "DAO for interstellar telescope launch",
            "some_image_url",
            "some_website_link",
            1500,  // DECIMAL == 18
            owner.getAddress()
        );
        await Token.deployed();

        // Airdrop Contract
        const AirdropContract = await ethers.getContractFactory("ScheduledAirDrop");
        
        TOKEN_ADDRESS = Token.address;
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

        const Airdrop = await AirdropContract.deploy(
            TOKEN_ADDRESS,
            AIRDROP_SNAPSHOT_TIMESTAMPS,
            ROUND_DURATION_IN_DAYS,
            NUM_OF_TOTAL_ROUNDS,
            AIRDROP_TARGET_ADDRESSES,
            AIRDROP_AMOUNTS_PER_ROUND_BY_ADDRESS,
            TOTAL_AIRDROP_VOLUME_PER_ROUND
        );

        return { TokenContract, Token, AirdropContract, Airdrop, owner, addr1, addr2, addr3 };
    }

    describe("Token contract Deployment", function() {
        it("Should assign the total supply of tokens to the contract address.", async function() {
            const {Token, owner} = await loadFixture(deployTokenFixture);
            const contractBalance = await Token.balanceOf(Token.address);
            expect(await Token.totalSupply()).to.equal(contractBalance);
            console.log("input data >>>> total token supply: ", await Token.totalSupply());

        });
    });

    describe("Airdrop contract match the token contract", function() {
        it("Airdrop contract matched to correct token contract.", async function() {
            const {Token, Airdrop, owner} = await loadFixture(deployTokenFixture);
            const DECIMAL = 18;

            const tokenInfo = await Airdrop.getTokenInfo();
            // expect(tokenInfo.totalSupply).to.equal(1500 * 10 ** DECIMAL);  // ERROR: the input value cannot be normalized to a BigInt.
            expect(tokenInfo.name).to.equal("TelescopeToken");
            expect(tokenInfo.symbol).to.equal("TELE");
            expect(tokenInfo.DAOName).to.equal("TelescopeDAO");
            expect(tokenInfo.intro).to.equal("DAO for interstellar telescope launch");
            expect(tokenInfo.image).to.equal("some_image_url");
            expect(tokenInfo.link).to.equal("some_website_link");
            expect(tokenInfo.owner).to.equal(owner.address);
            expect(tokenInfo.tokenContractAddress).to.equal(Token.address);
        });
    })

    describe("Airdrop contract deployment", async function() {
        it("Airdrop contract deployed successfully with correct constuctor params.", async function() {
            const {Token, Airdrop, addr1, addr2, addr3} = await loadFixture(deployTokenFixture);
    
            const tokenAddress = await Airdrop.getTokenAddress();
            const roundDurationInDays = await Airdrop.getRoundDurationInDays();
            const numOfTotalRounds = await Airdrop.getNumOfTotalRounds();
            const airdropTargetAddresses = await Airdrop.getAirdropTargetAddresses();
            const airdropAmountPerRoundByAddress1 = await Airdrop.getAirdropAmountPerRoundByAddress(addr1.address);
            const airdropAmountPerRoundByAddress2 = await Airdrop.getAirdropAmountPerRoundByAddress(addr2.address);
            const airdropAmountPerRoundByAddress3 = await Airdrop.getAirdropAmountPerRoundByAddress(addr3.address);
            const totalAirdropVolumePerRound = await Airdrop.getTotalAirdropVolumePerRound();

            expect(tokenAddress).to.equal(TelescopeToken.address);
            expect(roundDurationInDays).to.equal(7);
            expect(numOfTotalRounds).to.equal(5);
            expect(airdropTargetAddresses[0]).to.equal(addr1.address);
            expect(airdropTargetAddresses[1]).to.equal(addr2.address);
            expect(airdropTargetAddresses[2]).to.equal(addr3.address);
            expect(airdropAmountPerRoundByAddress1).to.equal(30);
            expect(airdropAmountPerRoundByAddress2).to.equal(50);
            expect(airdropAmountPerRoundByAddress3).to.equal(70);
            expect(totalAirdropVolumePerRound).to.equal(30 + 50 + 70);
        });
    });

    describe("Airdrop execution", async function() {
        it("", async function() {
            const {TokenContract, Token, AirdropContract, Airdrop, owner, addr1, addr2, addr3} = await loadFixture(deployTokenFixture);
            // TODO: test airdrop amount calculation for each airdrop rounds after token transfers
            // TODO: check block numbers between round intervals
            // TODO: test airdrop claim function call
        });
    });

});