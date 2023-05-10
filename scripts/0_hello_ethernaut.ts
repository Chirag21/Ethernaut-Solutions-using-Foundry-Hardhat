import { ethers } from "hardhat";
import { BLOCK_EXPLORER_URL, developmentNetworks } from "../hardhat.config";

async function helloEthernaut() {
  const helloEthernautInstanceAddress = process.env.HELLO_ETHERNAUT_ADDRESS!;
  const accounts = await ethers.getSigners();
  const attacker = accounts[0];
  const instance = await ethers.getContractAt("Instance", helloEthernautInstanceAddress);
  const password = await instance.password();
  const tx = await instance.connect(attacker).authenticate(password);

  if (ethers.provider.network.name in developmentNetworks)
    console.log(`Transaction hash : ${BLOCK_EXPLORER_URL}/${tx.hash}`);

  await tx.wait(1);
  console.log("SUCCESS!!! Submit the instance");
}

helloEthernaut().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
