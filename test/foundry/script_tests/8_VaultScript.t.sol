// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {VaultScript} from "script/8_VaultScript.sol";

interface IVault {
    function locked() external view returns (bool);
}

contract VaultScriptTest is Test {
    function test_VaultScript() external {
        VaultScript vaultScript = new VaultScript();
        vaultScript.run();

        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        IVault vault = IVault(vaultAddress);
        bool locked = vault.locked();

        assertFalse(locked, "VaultScriptTest : Failed to unlock the Vault");
    }
}
