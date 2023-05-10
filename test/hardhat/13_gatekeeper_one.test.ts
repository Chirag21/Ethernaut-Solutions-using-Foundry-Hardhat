import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { GatekeeperOne, GatekeeperOneHack } from "../../typechain-types";

describe("GatekeeperOne exploit", () => {
  async function deployGateKeeperOneFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const GatekeeperOneFactory = await ethers.getContractFactory("GatekeeperOneFactory");
    const gatekeeperOneFactory = await GatekeeperOneFactory.connect(deployer).deploy();
    await gatekeeperOneFactory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const gateKeeperOneAddress = await gatekeeperOneFactory
      .connect(attacker)
      .callStatic.createInstance(attacker.address);

    // Create a level instance
    const tx = await gatekeeperOneFactory.createInstance(attacker.address);
    await tx.wait(1);

    // Get deployed instance of Elevator contract
    const gatekeeperOne = await ethers.getContractAt("GatekeeperOne", gateKeeperOneAddress);

    const GatekeeperOneHack = await ethers.getContractFactory("GatekeeperOneHack");
    const gatekeeperOneHack = await GatekeeperOneHack.deploy();
    await gatekeeperOneHack.deployed();

    return { attacker, gatekeeperOne, gatekeeperOneFactory, gatekeeperOneHack };
  }

  it("Should register as an entrant", async () => {
    const { attacker, gatekeeperOne, gatekeeperOneFactory, gatekeeperOneHack } = await loadFixture(
      deployGateKeeperOneFixture
    );

    const tx = await gatekeeperOneHack.connect(attacker).hack(gatekeeperOne.address);
    await tx.wait(1);

    const entrant = await gatekeeperOne.entrant();
    const attackerAddress = await attacker.getAddress();

    console.log(entrant);
    console.log(attackerAddress);

    expect(entrant).to.be.equal(attackerAddress, "Did register the entrant");

    const success = await gatekeeperOneFactory
      .connect(attacker)
      .callStatic.validateInstance(gatekeeperOne.address, attackerAddress);
    expect(success).to.be.true;
  });
});
