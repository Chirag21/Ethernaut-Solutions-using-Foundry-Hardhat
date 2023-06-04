import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Preservation Hack", () => {
  async function deployPreservationFixture() {
    const [attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const PreservationFactory = await ethers.getContractFactory("PreservationFactory");
    const factory = await PreservationFactory.deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const preservationAddress = await factory.connect(attacker).callStatic.createInstance(attackerAddress);

    // Deploy instance of level
    const tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    // Get deployed instance of GatekeeperTwo contract
    const preservation = await ethers.getContractAt("Preservation", preservationAddress);
    return { attacker, factory, preservation };
  }

  it("Should claim ownership of the instance you are given", async () => {
    const { attacker, factory, preservation } = await loadFixture(deployPreservationFixture);

    const attackerAddr = await attacker.getAddress();

    const PreservationHack = await ethers.getContractFactory("PreservationHack");
    const preservationHack = await PreservationHack.connect(attacker).deploy();
    await preservationHack.deployed();

    const tx = await preservationHack.connect(attacker).hack(preservation.address);
    await tx.wait(1);

    expect(await preservation.owner()).to.be.eq(attackerAddr, "Hack Failed!!!");

    const success = await factory.validateInstance(preservation.address, attackerAddr);
    expect(success).to.be.eq(true, "Failed to submit the instance!!!");
  });
});
