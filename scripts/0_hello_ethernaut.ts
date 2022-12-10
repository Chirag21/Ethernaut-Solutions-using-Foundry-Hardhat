import hre, { ethers } from "hardhat";
import { BLOCK_EXPLORER_URL } from "../hardhat.config";

async function helloEthernaut() {
  const helloEthernautInstanceAddress = process.env.HELLO_ETHERNAUT_ADDRESS!;
  const accounts = await ethers.getSigners();
  const attacker = accounts[0];
  const instance = await ethers.getContractAt("Instance", helloEthernautInstanceAddress);
  const password = await instance.password();
  const tx = await instance.connect(attacker).authenticate(password);
  console.log(`${BLOCK_EXPLORER_URL}/${tx.hash}`);
  await tx.wait();
  console.log("SUCCESS!!! Submit the instance");
}

helloEthernaut().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
