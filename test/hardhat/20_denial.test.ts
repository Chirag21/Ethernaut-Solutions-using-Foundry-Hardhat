import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

const INITIAL_DEPOSIT = ethers.utils.parseEther("0.001");

describe("Denial Hack", async () => {
  async function deployDenialFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const DenialFactory = await ethers.getContractFactory("DenialFactory");
    const factory = await DenialFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const denialAddress = await factory
      .connect(attacker)
      .callStatic.createInstance(attackerAddress, { value: INITIAL_DEPOSIT });

    // Deploy instance of level
    const tx = await factory.connect(attacker).createInstance(attackerAddress, { value: INITIAL_DEPOSIT });
    await tx.wait(1);

    const denial = await ethers.getContractAt("Denial", denialAddress);
    return { attacker, factory, denial };
  }

  it("Deny the owner from withdrawing the funds", async () => {
    const { attacker, factory, denial } = await loadFixture(deployDenialFixture);

    const DenialHack = await ethers.getContractFactory("DenialHack");
    const denialHack = await DenialHack.connect(attacker).deploy();
    await denialHack.deployed();
    let tx = await denial.setWithdrawPartner(denialHack.address);
    await tx.wait(1);

    // simulate onchain transaction to get return value of the function
    const success = await factory
      .connect(attacker)
      .callStatic.validateInstance(denial.address, await attacker.getAddress());
    expect(success).to.be.eq(true, "Failed to validate the instance!!!");
  });
});
