const { expect } = require("chai");

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage or Hardhat Network's snapshot functionality.
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const {BigNumber} = require("ethers");

describe("Token contract", function () {
  async function deployTokenFixture() {
    const Token = await ethers.getContractFactory("TelescopeToken");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatToken = await Token.deploy("TelescopeToken", "TELE",
        "Telescope DAO", "This DAO is for Telescope",
        "https://www.istockphoto.com/photos/astronomy-telescope-no-people-white-background-isolated-on-white",
        "https://telescope.io", 1000000
    );

    await hardhatToken.deployed();

    return {Token, hardhatToken, owner, addr1, addr2};
  }

  describe("Deployment", function () {

    it("Should assign the total supply of tokens to the owner", async function () {
      const {hardhatToken, owner} = await loadFixture(deployTokenFixture);
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const {hardhatToken, owner, addr1, addr2} = await loadFixture(deployTokenFixture);
      // Transfer 50 tokens from owner to addr1
      await expect(hardhatToken.transfer(addr1.address, 50))
          .to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
          .to.changeTokenBalances(hardhatToken, [addr1, addr2], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const {hardhatToken, owner, addr1, addr2} = await loadFixture(deployTokenFixture);

      // Transfer 50 tokens from owner to addr1
      await expect(hardhatToken.transfer(addr1.address, 50))
          .to.emit(hardhatToken, "Transfer").withArgs(owner.address, addr1.address, 50)

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
          .to.emit(hardhatToken, "Transfer").withArgs(addr1.address, addr2.address, 50)
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const {hardhatToken, owner, addr1} = await loadFixture(deployTokenFixture);
      const initialOwnerBalance = await hardhatToken.balanceOf(
          owner.address
      );

      // Try to send 1 token from addr1 (0 tokens) to owner (1000 tokens).
      // `require` will evaluate false and revert the transaction.
      await expect(
          hardhatToken.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      // Owner balance shouldn't have changed.
      expect(await hardhatToken.balanceOf(owner.address)).to.equal(
          initialOwnerBalance
      );
    });
  });

  describe("Transfer Tokens", async function () {
    it("Should store balanceUpdateHistories after transfering tokens between accounts", async () => {
      // given
      const {hardhatToken, owner, addr1, addr2} = await loadFixture(deployTokenFixture);

      // when: Transfer 50 tokens from owner to addr1
      expect(await hardhatToken.transfer(addr1.address, ethers.utils.parseUnits('50', 18)));

      // then
      const historiesOfOwnerFirstCase = await hardhatToken.getBalanceUpdateHistoryByAddress(owner.address);

      expect(historiesOfOwnerFirstCase.length).to.equal(1);
      expect(historiesOfOwnerFirstCase[0].blockNumber).to.equal(2);
      expect(historiesOfOwnerFirstCase[0].balanceAfterCommit).to.equal(ethers.utils.parseUnits('999950', 18));

      const historiesOfAddr1FirstCase = await hardhatToken.getBalanceUpdateHistoryByAddress(addr1.address);
      expect(historiesOfAddr1FirstCase.length).to.equal(1);
      expect(historiesOfAddr1FirstCase[0].blockNumber).to.equal(2);
      expect(historiesOfAddr1FirstCase[0].balanceAfterCommit).to.equal(ethers.utils.parseUnits('50', 18));

      // when: Transfer 50 tokens from addr1 to addr2 to use connect(signer) to send a transaction from another account
      expect(await hardhatToken.connect(addr1).transfer(addr2.address, ethers.utils.parseUnits('30', 18)));

      // then
      const historiesOfAddr1SecondCase = await hardhatToken.getBalanceUpdateHistoryByAddress(addr1.address);
      expect(historiesOfAddr1SecondCase.length).to.equal(2);
      expect(historiesOfAddr1SecondCase[1].blockNumber).to.equal(3);
      expect(historiesOfAddr1SecondCase[1].balanceAfterCommit).to.equal(ethers.utils.parseUnits('20', 18));

      const historiesOfAddr2SecondCase = await hardhatToken.getBalanceUpdateHistoryByAddress(addr2.address);
      expect(historiesOfAddr2SecondCase.length).to.equal(1);
      expect(historiesOfAddr2SecondCase[0].blockNumber).to.equal(3);
      expect(historiesOfAddr2SecondCase[0].balanceAfterCommit).to.equal(ethers.utils.parseUnits('30', 18));
    })
  });
});