// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Preservation} from "src/levels/Preservation.sol";
import {PreservationFactory} from "src/levels/PreservationFactory.sol";
import {PreservationHack} from "src/hack/PreservationHack.sol";

contract PreservationTest is Test {
    PreservationFactory private factory;
    Preservation private preservation;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        factory = new PreservationFactory();
        address preservationAddr = factory.createInstance(attacker);
        preservation = Preservation(preservationAddr);
    }

    function test_PreservationTest() external {
        vm.startPrank(attacker, attacker);
        PreservationHack preservationHack = new PreservationHack();

        preservationHack.hack(address(preservation));

        assertEq(attacker, preservation.owner(), "Failed to set the owner!!!");

        bool success = factory.validateInstance(
            payable(address(preservation)),
            attacker
        );

        assertTrue(success, "Failed to submit the instance!!!");

        vm.stopPrank();
    }
}
