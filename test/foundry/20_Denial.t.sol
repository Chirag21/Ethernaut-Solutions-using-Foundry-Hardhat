// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Denial} from "src/levels/Denial.sol";
import {DenialFactory} from "src/levels/DenialFactory.sol";
import {DenialHack} from "src/hack/DenialHack.sol";

contract DenialTest is Test {
    DenialFactory private factory;
    Denial private denial;
    address private attacker = makeAddr("attacker");
    uint256 public initialDeposit = 0.001 ether;

    function setUp() external {
        factory = new DenialFactory();
        hoax(attacker, attacker, 1 ether);
        address denialAddress = factory.createInstance{value: initialDeposit}(
            attacker
        );
        denial = Denial(payable(denialAddress));
    }

    function test_DenialHack() external {
        vm.startPrank(attacker, attacker);
        DenialHack hack = new DenialHack();
        denial.setWithdrawPartner(address(hack));

        assertTrue(
            factory.validateInstance(payable(address(denial)), attacker),
            "Failed to validate the instance!!!"
        );
        vm.stopPrank();
    }
}
