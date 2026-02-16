import { expect } from "chai";
import { ethers } from "hardhat";

describe("HashRewards", function () {

  async function deployFixture() {
    const [owner, user] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("HashRewards");
    const contract = await Factory.deploy();
    await contract.waitForDeployment();

    return { contract, owner, user };
  }

  it("initializes with predefined quests", async function () {
    const { contract } = await deployFixture();

    const quest = await contract.getQuest(1);

    expect(quest.id).to.equal(1n);
    expect(quest.rewardPoints).to.equal(10n);
    expect(quest.active).to.equal(true);
  });

  it("awards points when completing quest", async function () {
    const { contract, user } = await deployFixture();

    const hash = ethers.keccak256(
      ethers.toUtf8Bytes("test")
    );

    await contract.connect(user).completeQuest(1, hash);

    const points = await contract.getUserPoints(user.address);
    expect(points).to.equal(10n);

    const receipts = await contract.getUserReceipts(user.address);
    expect(receipts.length).to.equal(1);
    expect(receipts[0].receiptHash).to.equal(hash);
  });

  it("reverts for invalid quest", async function () {
    const { contract, user } = await deployFixture();

    const hash = ethers.keccak256(
      ethers.toUtf8Bytes("test")
    );

    await expect(
      contract.connect(user).completeQuest(999, hash)
    ).to.be.reverted;
  });

});
