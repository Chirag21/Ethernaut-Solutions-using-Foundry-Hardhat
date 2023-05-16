import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Shop Hack", async () => {
  async function deployShopFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const ShopFactory = await ethers.getContractFactory("ShopFactory");
    const factory = await ShopFactory.connect(deployer).deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const shopAddress = await factory.connect(attacker).callStatic.createInstance(attackerAddress);

    // deploy the instance
    const tx = await factory.connect(attacker).createInstance(attackerAddress);
    await tx.wait(1);

    const shop = await ethers.getContractAt("Shop", shopAddress);
    return { attacker, shop, factory };
  }

  it("Should buy item from shop for less price", async () => {
    const { attacker, shop, factory } = await loadFixture(deployShopFixture);

    const ShopHack = await ethers.getContractFactory("ShopHack");
    const shopHack = await ShopHack.connect(attacker).deploy(shop.address);
    await shopHack.deployed();

    const initialPrice = await shop.price();

    const tx = await shopHack.hack();
    await tx.wait(1);

    const newPrice = await shop.price();

    expect(newPrice.lt(initialPrice)).to.be.equal(true, "Hack Failed!!!");

    const attackerAddress = await attacker.getAddress();
    const success = await factory.validateInstance(shop.address, attackerAddress);
    expect(success).to.be.equal(true, "Failed To Validate The Instance!!!");
  });
});
