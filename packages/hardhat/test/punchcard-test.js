const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PunchCard", function () {
  this.timeout(50000);

  let punchCard;
  let owner;
  let acc1;
  let acc2;

  this.beforeEach(async function() {
      // This is executed before each test
      // Deploying the smart contract
      const PunchCard = await ethers.getContractFactory("PunchCard");
      [owner] = await ethers.getSigners();
      [acc1, acc2] = [
        ethers.Wallet.createRandom(), ethers.Wallet.createRandom()
      ]
      punchCard = await PunchCard.deploy();
  })

  it("Should set the right owner", async function () {
      expect(await punchCard.owner()).to.equal(owner.address);
  });

  it("Should mint one NFT", async function() {
      expect(await punchCard.balanceOf(acc1.address)).to.equal(0);
      
      const tokenURI = "https://example.com/1"
      const tx = await punchCard.connect(owner).safeMint(acc1.address, tokenURI);
      await tx.wait();

      expect(await punchCard.balanceOf(acc1.address)).to.equal(1);
  })

  it("Should set the correct tokenURI", async function() {
      const tokenURI_1 = "https://example.com/1"
      const tokenURI_2 = "https://example.com/2"

      const tx1 = await punchCard.connect(owner).safeMint(acc1.address, tokenURI_1);
      await tx1.wait();
      const tx2 = await punchCard.connect(owner).safeMint(acc2.address, tokenURI_2);
      await tx2.wait();

      expect(await punchCard.tokenURI(0)).to.equal(tokenURI_1);
      expect(await punchCard.tokenURI(1)).to.equal(tokenURI_2);
  })
});