const { expect } = require("chai");
const { ethers } = require("hardhat");

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage or Hardhat Network's snapshot functionality.
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const {BigNumber, utils} = require("ethers");

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


describe("Token & Airdrop contracts test", function() {
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
            owner.getAddress(),
            1500  // DECIMAL == 18
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

        return { Token, Airdrop, owner, addr1, addr2, addr3 };
    }

    describe("Token transfer", async function() {
        it("Should transfer ERC20Trackable token between accounts successfully.", async function() {
            const {Token, owner, addr1, addr2, addr3} = await loadFixture(deployTokenFixture);
            
            console.log(">>> initial token contract balance in ETH unit: ", utils.formatEther(await Token.balanceOf(Token.address)));

            // avoid OVERFLOW: use BigNumber operations from ethers.js
            // Transfer 1000 tokens: ( contract => owner )
            
            // const _initialTokenTransferAmount = BigNumber.from("1000").mul(BigNumber.from("10").pow(18));
            // const _initialTokenTransferAmount = utils.parseEther("1000");

            expect(await Token.airdropFromContractAccount(owner.address, utils.parseEther("1000")))
            .to.changeTokenBalances(Token, [Token, owner], [utils.parseEther("-1000"), utils.parseEther("1000")]);
            console.log(">>> Token contract balance after the initial transfer in ETH unit: ", utils.formatEther(await Token.balanceOf(Token.address)));

            // Transfer 300 tokens: ( owner => addr1 )
            expect(await Token.connect(owner).transfer(addr1.address, utils.parseEther("300")))
            .to.changeTokenBalances(Token, [owner, addr1], [utils.parseEther("-300"), utils.parseEther("300")]);

            // Transfer 150 tokens: (addr1 => addr2 )
            expect(await Token.connect(addr1).transfer(addr2.address, utils.parseEther("150")))
            .to.changeTokenBalances(Token, [addr1, addr2], [utils.parseEther("-150"), utils.parseEther("150")]);

            console.log(">>>>>> After transfer <<<<<<");
            console.log(">>> contract balance: ", utils.formatEther(await Token.balanceOf(Token.address)));
            console.log(">>> owner's balance: ", utils.formatEther(await Token.balanceOf(owner.address)));
            console.log(">>> addr1's balance: ", utils.formatEther(await Token.balanceOf(addr1.address)));
            console.log(">>> addr2's balance: ", utils.formatEther(await Token.balanceOf(addr2.address)));
            console.log(">>> addr3's balance: ", utils.formatEther(await Token.balanceOf(addr3.address)));
        });
        it("should emit Transfer events", async function () {
            const {Token, addr1, addr2} = await loadFixture(deployTokenFixture);
      
            // airdrop from the token contract
            expect(await Token.airdropFromContractAccount(addr1.address, utils.parseEther("100")))
                .to.emit(Token, "Transfer").withArgs(Token.address, addr1.address, utils.parseEther("100"));
            
            // token transfer between EOA
            expect(await Token.connect(addr1).transfer(addr2.address, utils.parseEther("100")))
                .to.emit(Token, "Transfer").withArgs(addr1.address, addr2.address, utils.parseEther("100"));
        });
      
        it("Should fail if sender doesn't have enough tokens", async function () {
            const {Token, owner, addr1} = await loadFixture(deployTokenFixture);
            const initialOwnerBalance = await Token.balanceOf(owner.address);  // is zero
      
            // Try to send 1 token from addr1 (0 tokens) to owner.
            // `require` will evaluate false and revert the transaction.
            await expect(Token.connect(addr1).transfer(owner.address, utils.parseEther("1")))
            .to.be.revertedWith("ERC20: transfer amount exceeds balance");
      
            // Owner balance shouldn't have changed.
            expect(await Token.balanceOf(owner.address)).
            to.equal(initialOwnerBalance);
        });
    });

    describe("Token contract Deployment", function() {
        it("Should assign the total supply of tokens to the contract address.", async function() {
            const {Token, owner} = await loadFixture(deployTokenFixture);
            const contractBalance = await Token.balanceOf(Token.address);
            expect(await Token.totalSupply()).to.equal(contractBalance);
            console.log("input data >>>> total token supply: ", await Token.totalSupply());
        });
        it("Should not assign tokens to addresses other than the token contract.", async function() {
            const {Token, owner, addr1, addr2, addr3} = await loadFixture(deployTokenFixture);
            expect(await Token.balanceOf(owner.address)).to.equal(0);
            expect(await Token.balanceOf(addr1.address)).to.equal(0);
            expect(await Token.balanceOf(addr2.address)).to.equal(0);
            expect(await Token.balanceOf(addr3.address)).to.equal(0);
        });
    });

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

            expect(tokenAddress).to.equal(Token.address);
            expect(roundDurationInDays).to.equal(7000);
            expect(numOfTotalRounds).to.equal(5);
            expect(airdropTargetAddresses[0]).to.equal(addr1.address);
            expect(airdropTargetAddresses[1]).to.equal(addr2.address);
            expect(airdropTargetAddresses[2]).to.equal(addr3.address);
            expect(airdropAmountPerRoundByAddress1).to.equal(utils.parseEther("30"));
            expect(airdropAmountPerRoundByAddress2).to.equal(utils.parseEther("50"));
            expect(airdropAmountPerRoundByAddress3).to.equal(utils.parseEther("70"));
            expect(totalAirdropVolumePerRound).to.equal(utils.parseEther("150"));
        });
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
    });

    describe("Airdrop execution", async function() {
        it("", async function() {
            const {Token, Airdrop, owner, addr1, addr2, addr3} = await loadFixture(deployTokenFixture);
            console.log("\n========================= Airdrop Execution =========================\n");

            // console.log("Token Info: ", await Airdrop.getTokenInfo());
            const tokenInfo = await Airdrop.getTokenInfo();
            const tokenSymbol = tokenInfo.symbol;
            console.log("\nNum of total rounds: ", await Airdrop.getNumOfTotalRounds());
            console.log("\nRound duration: ", await Airdrop.getRoundDurationInDays(), "days");
            console.log("\nTotal airdrop volume per round: ", utils.formatEther(await Airdrop.getTotalAirdropVolumePerRound()), tokenSymbol);
            console.log("\nAirdrop allowlist: ", await Airdrop.getAirdropTargetAddresses());
            console.log("\nAirdrop Snapshot Timestamps: ", await Airdrop.getAirdropSnapshotTimestamps());
            
            // Airdrop.getAirdropAmountPerRoundByAddress()
            // Airdrop.getTotalAirdropVolumePerRound()
            // Airdrop.getCalculatedAirdropAmountPerRoundByAddress()
            // Airdrop.getInitialBlockNumberByRound()

            console.log("================ Token Balances before airdrop round #1 ================");
            console.log("Contract: ", utils.formatEther(await Token.balanceOf(Token.address)), tokenSymbol);
            console.log("addr1: ", utils.formatEther(await Token.balanceOf(addr1.address)), tokenSymbol);
            console.log("addr2: ", utils.formatEther(await Token.balanceOf(addr2.address)), tokenSymbol);
            console.log("addr3: ", utils.formatEther(await Token.balanceOf(addr3.address)), tokenSymbol);
            
            await Airdrop.initiateAirdropRound();

            console.log("Claimmable token amount of addr1 for round 1: ", utils.formatEther(await Airdrop.getCalculatedAirdropAmountPerRoundByAddress(1, addr1.address)), tokenSymbol);
            console.log("Claimmable token amount of addr2 for round 1: ", utils.formatEther(await Airdrop.getCalculatedAirdropAmountPerRoundByAddress(1, addr2.address)), tokenSymbol);
            console.log("Claimmable token amount of addr3 for round 1: ", utils.formatEther(await Airdrop.getCalculatedAirdropAmountPerRoundByAddress(1, addr3.address)), tokenSymbol);
            
            await Airdrop.connect(addr1).claimAirdrop(1);
            await Airdrop.connect(addr2).claimAirdrop(1);
            await Airdrop.connect(addr3).claimAirdrop(1);

            console.log("\n================ Token Balances after airdrop round #1 ================");
            console.log("Contract: ", utils.formatEther(await Token.balanceOf(Token.address)), tokenSymbol);
            console.log("addr1: ", utils.formatEther(await Token.balanceOf(addr1.address)), tokenSymbol);
            console.log("addr2: ", utils.formatEther(await Token.balanceOf(addr2.address)), tokenSymbol);
            console.log("addr3: ", utils.formatEther(await Token.balanceOf(addr3.address)), tokenSymbol);
            
        });
    });
});