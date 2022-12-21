import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Telephone exploit", () => {
  async function deployTelephoneFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    const Telephone = await ethers.getContractFactory("Telephone");
    const telephone = await Telephone.connect(deployer).deploy();

    const TelephoneHack = await ethers.getContractFactory("TelephoneHack");
    const telephoneHack = await TelephoneHack.connect(attacker).deploy(telephone.address);

    return { attacker, telephone, telephoneHack };
  }

  it("Changes the owner to attacker", async () => {
    const { attacker, telephone, telephoneHack } = await loadFixture(deployTelephoneFixture);

    const tx = await telephoneHack.connect(attacker).changeOwner(attacker.address);
    await tx.wait();

    const ownerAfterHack = await telephone.owner();

    // Assert the new owner
    expect(attacker.address).to.be.equal(ownerAfterHack, "The New Owner Is Not Set ");
  });
});
