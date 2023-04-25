// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {GatekeeperTwoFactory} from "src/levels/GatekeeperTwoFactory.sol";
import {GatekeeperTwo} from "src/levels/GatekeeperTwo.sol";
import {GatekeeperTwoHack} from "src/hack/GatekeeperTwoHack.sol";

contract GatekeeperTwoTest is Test {
    GatekeeperTwoFactory private factory;
    GatekeeperTwo private gatekeeperTwo;
    address private attacker = makeAddr("attacker");

    error HackFailed();

    function setUp() external {
        factory = new GatekeeperTwoFactory();
        address gatekeeperTwoAddress = factory.createInstance(attacker);
        gatekeeperTwo = GatekeeperTwo(gatekeeperTwoAddress);
    }

    function test_GatekeeperTwoHack() external {
        vm.startPrank(attacker, attacker);

        // Code in the constructor will hack the level.
        new GatekeeperTwoHack(address(gatekeeperTwo));

        assertEq(gatekeeperTwo.entrant(), attacker, "Hack Failed!!!");

        if (
            factory.validateInstance(payable(address(gatekeeperTwo)), attacker)
        ) {
            vm.stopPrank();
            return;
        }
        revert HackFailed();
    }
}
