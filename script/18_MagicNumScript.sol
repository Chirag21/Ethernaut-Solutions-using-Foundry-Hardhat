// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20.;

import {MagicNum} from "src/levels/MagicNum.sol";
import "forge-std/Script.sol";

contract MagiNUmSCript is Script {
    function run() external {
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        address magicNumAddress = vm.envAddress("MAGIC_NUMBER_ADDRESS");
        MagicNum magicNum = MagicNum(magicNumAddress);

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
        
        address solverAddress;
        assembly{
            let bytecode := hex"69602a60005260206000f3600052600a6016f3"
            mstore(0, bytecode)
            solverAddress := create(0,0,19)
        }

        vm.startBroadcast(attacker);

        (bool success,bytes memory data) = solverAddress.call(hex"650500c1");
        assert(42 == uint256(bytes32(data)));

        magicNum.setSolver(solverAddress);

        vm.stopBroadcast();

        console2.log("SUCCESS!!! Submit the instance.");

    }
}
