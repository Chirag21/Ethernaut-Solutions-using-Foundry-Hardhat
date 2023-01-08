// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ForceFactory} from "src/levels/ForceFactory.sol";
import {Force} from "src/levels/Force.sol";
import {ForceHack} from "src/hack/ForceHack.sol";

contract ForceTest is Test {
    ForceFactory private forceFactory;
    ForceHack private forceHack;
    address private attacker = makeAddr("attacker");
    address private forceAddress;

    function setUp() external {
        forceFactory = new ForceFactory();
        forceAddress = forceFactory.createInstance(attacker);
    }

    function test_ForceHack() external {
        // Deploy the ForceHack contract.
        // "selfdestruct" function in the constructor will send ether stored in the contract to the supplied address.
        new ForceHack{value: 1 wei}(payable(forceAddress));

        // Validate the instance using Ethernaut validation.
        bool success = forceFactory.validateInstance(
            payable(forceAddress),
            attacker
        );

        // Assert Force's contract balance is greater than zero.
        assertTrue(success, "Validation Failed!!!");
    }
}
