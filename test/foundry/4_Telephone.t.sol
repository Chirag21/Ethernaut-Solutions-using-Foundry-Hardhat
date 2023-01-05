// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {TelephoneFactory} from "src/levels/TelephoneFactory.sol";
import {Telephone} from "src/levels/Telephone.sol";
import {TelephoneHack} from "src/hack/TelephoneHack.sol";

contract TelephoneTest is Test {
    TelephoneHack private telephoneHack;
    TelephoneFactory private telephoneFactory;
    address private attacker = makeAddr("attacker");
    Telephone private telephone;

    constructor() {
        telephoneFactory = new TelephoneFactory();
        address addr = telephoneFactory.createInstance(attacker);
        telephone = Telephone(addr);
        telephoneHack = new TelephoneHack(address(telephone));
    }

    function testTelephoneHack() external {
        vm.startPrank(attacker);
        telephoneHack.changeOwner(attacker);
        address ownerAfterAttack = telephone.owner();

        // Assert the new owner
        assertEq(attacker, ownerAfterAttack, "The New Owner Is Not Set");

        // Validate instance using Ethernaut validation
        telephoneFactory.validateInstance(
            payable(address(telephone)),
            attacker
        );
        vm.stopPrank();
    }
}
