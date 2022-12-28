// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {King} from "src/levels/King.sol";
import {KingFactory} from "src/levels/KingFactory.sol";
import {KingHack} from "src/test/KingHack.sol";

contract KingTest is Test {
    KingFactory private kingFactory;
    King private king;
    KingHack private kingHack;
    uint256 private constant INSERT_COIN = 0.001 ether;

    // Create an address derived from string
    address private attacker = makeAddr("Address");

    function setUp() external {
        kingFactory = new KingFactory();
        address kingAddress = kingFactory.createInstance{value: INSERT_COIN}(
            attacker
        );
        king = King(payable(kingAddress));
        kingHack = new KingHack();
    }

    function testKingHack() external {
        // Fund attacker address with ether
        vm.deal(attacker, 1 ether);

        // Following this, for all the transactions, msg.sender will be the attacker
        vm.startPrank(attacker);

        // Perform hack. This causes the KingHack contract to assume kingship of the King contract.
        kingHack.hack{value: INSERT_COIN}(address(king));

        address kingBeforeSubmit = king._king();

        // Since the KingHack contract does not have receive or payable fallback functions, level cannot reclaim kingship.
        bool success = kingFactory.validateInstance(payable(king), attacker);

        // Validate using Ethernaut validation
        assertTrue(success);

        address kingAfterSubmit = king._king();
        assertEq(kingBeforeSubmit, kingAfterSubmit, "Attack Failed!!!");

        vm.stopPrank();
    }
}
