import { fail } from "assert";
import { ethers } from "hardhat";

async function magicNumScript() {
  const magicNumAddress = process.env.MAGIC_NUMBER_ADDRESS || fail("MAGIC_NUMBER_ADDRESS Not Found in .env");
  const [attacker] = await ethers.getSigners();
  const magicNum = await ethers.getContractAt("MagicNum", magicNumAddress);

  // No matter the function selector, following code will always return 42.
  /*  This is the runtime code  0x69604260005260206000f3
      PUSH1  0x2a    |   602a     // 0x2a = 42
      PUSH1  0x00    |   6000
      MSTORE         |   52 
      PUSH1  0x20    |   6020
      PUSH1  0x00    |   6000
      RETURN         |   f3
    
      */

  /*  This is the Initialization code that will deploy runtime code
      PUSH10 0x10    |   69604260005260206000f3
      PUSH1  0x00    |   6000
      MSTORE         |   52 
      PUSH1  0x0a    |   600a
      PUSH1  0x16    |   6016
      RETURN         |   f3
    */

  const bytecode = "0x69602a60005260206000f3600052600a6016f3";
  const txResponse = await attacker.sendTransaction({ data: bytecode });
  const txReceipt = await txResponse.wait(1);
  const solverAddress = txReceipt.contractAddress;

  const num = await attacker.call({ to: solverAddress, data: bytecode });
  console.log("MagicNum returned : ", Number.parseInt(num));

  const tx = await magicNum.setSolver(solverAddress);
  await tx.wait(1);

  console.log("SUCCESS!!! Submit the instance.");
}

magicNumScript().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
