import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Gatekeeper Two Exploit", () => {
  async function deployGatekeeperTwoFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const GateKeeperTwoFactory = await ethers.getContractFactory("GatekeeperTwoFactory");
    const gatekeeperTwoFactory = await GateKeeperTwoFactory.connect(deployer).deploy();
    await gatekeeperTwoFactory.deployed();

    const attackerAddress = await attacker.getAddress();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const gateKeeperTwoAddress = await gatekeeperTwoFactory
      .connect(attacker)
      .callStatic.createInstance(attackerAddress);

    // Create Instance
    const tx = await gatekeeperTwoFactory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    // Get deployed instance of GatekeeperTwo contract
    const gatekeeperTwo = await ethers.getContractAt("GatekeeperTwo", gateKeeperTwoAddress);

    return { attacker, gatekeeperTwoFactory, gatekeeperTwo };
  }

  it("Should register attacker contract as entrant", async () => {
    const { attacker, gatekeeperTwoFactory, gatekeeperTwo } = await loadFixture(deployGatekeeperTwoFixture);

    // Deploy GatekeeperTwoHack contract.
    // The code in constructor will perform the hack
    const GatekeeperTwoHack = await ethers.getContractFactory("GatekeeperTwoHack");
    const gatekeeperTwoHack = await GatekeeperTwoHack.connect(attacker).deploy(gatekeeperTwo.address);
    await gatekeeperTwoHack.deployed();

    const entrant = await gatekeeperTwo.entrant();
    const attackerAddress = await attacker.getAddress();

    expect(entrant).to.be.equal(attackerAddress, "Hack Failed!!!");

    const success = await gatekeeperTwoFactory
      .connect(attacker)
      .validateInstance(gatekeeperTwo.address, attackerAddress);

    expect(success).to.be.true;
  });
});
