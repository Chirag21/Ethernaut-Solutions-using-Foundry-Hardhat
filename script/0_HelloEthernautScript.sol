//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface IInstance {
    function password() external view returns (string memory);

    function authenticate(string memory) external;
}

contract HackHelloEthernautScript is Script {
    function run() external {
        IInstance instance = IInstance(
            vm.envAddress("HELLO_ETHERNAUT_ADDRESS")
        );

        // Get private key from .env file
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(attackerKey);

        string memory password = instance.password();
        instance.authenticate(password);

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
