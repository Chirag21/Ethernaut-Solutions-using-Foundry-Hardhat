import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

const MAGIC_NUM = 42;

describe("MagicNumber Hack", async () => {
  async function deployMagicNumber() {
    const [deployer, attacker] = await ethers.getSigners();
    const MagicNumFactory = await ethers.getContractFactory("MagicNumFactory");
    const attackerAddress = await attacker.getAddress();
    const factory = await MagicNumFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const magicNumAddress = await factory.connect(attacker).callStatic.createInstance(attackerAddress);

    // Deploy instance of level
    const tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    const magicNum = await ethers.getContractAt("MagicNum", magicNumAddress);

    return { attacker, factory, magicNum };
  }

  it("Should solve the level", async () => {
    const { attacker, factory, magicNum } = await loadFixture(deployMagicNumber);

    // No matter the function selector, following code will always return 42.
    /*  This is the runtime code  0x69604260005260206000f3
      PUSH1  0x2a    |   602a     // 0x2a = 42
      PUSH1  0x00    |   6000
      MSTORE         |   52 
      PUSH1  0x20    |   6020
      PUSH1  0x00    |   6000
      RETURN         |   f3
    
      */

    /*  This is the Initialization code that will deploy runtime code
      PUSH10 0x10    |   69604260005260206000f3
      PUSH1  0x00    |   6000
      MSTORE         |   52 
      PUSH1  0x0a    |   600a
      PUSH1  0x16    |   6016
      RETURN         |   f3
    */

    const bytecode = "0x69602a60005260206000f3600052600a6016f3";
    const txResponse = await attacker.sendTransaction({ data: bytecode });
    const txReceipt = await txResponse.wait(1);
    const solverAddress = txReceipt.contractAddress;

    // Call deployed bytecode. This will return 42.
    const num = await attacker.call({ to: solverAddress, data: "0x650500c1" });
    expect(Number.parseInt(num)).to.be.equal(MAGIC_NUM, "Failed to return 42!!!");

    // Set Solver address
    const tx = await magicNum.setSolver(solverAddress);
    await tx.wait(1);

    const success = await factory.validateInstance(magicNum.address, attacker.address);
    expect(success).to.be.eq(true, "Failed to validate the instance!!!");
  });
});
