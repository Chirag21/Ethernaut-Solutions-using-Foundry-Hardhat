// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {MagicNum} from "src/levels/MagicNum.sol";
import {MagicNumFactory} from "src/levels/MagicNumFactory.sol";

contract MagicNumTest is Test {
    error CallFailed();

    address attacker = makeAddr("attacker");
    MagicNum private magicNum;
    MagicNumFactory private factory;
    uint constant MAGIC_NUM = 42;

    function setUp() external {
        factory = new MagicNumFactory();
        address magicNumAddress = factory.createInstance(attacker);
        magicNum = MagicNum(magicNumAddress);
    }

    function test_MagicNumHack() external {
        vm.startPrank(attacker, attacker);

        // No matter the function selector, following code will always return 42.
        /*  This is the runtime code    0x69604260005260206000f3
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
        assembly {
            let bytecode := hex"69602a60005260206000f3600052600a6016f3"
            mstore(0, bytecode)
            solverAddress := create(0, 0, 19)
        }

        // Call deployed bytecode. This will return 42.
        (bool success, bytes memory num) = address(solverAddress).call(
            hex"650500c1"
        );
        if (!success) revert CallFailed();
        assertEq(uint256(bytes32(num)), MAGIC_NUM, "Failed to return 42!!!");

        magicNum.setSolver(solverAddress);

        success = factory.validateInstance(
            payable(address(magicNum)),
            attacker
        );
        assertTrue(success, "Failed to validate instance!!!");
        vm.stopPrank();
    }
}
