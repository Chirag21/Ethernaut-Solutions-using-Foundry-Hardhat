// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Script.sol";
import {GatekeeperTwoHack} from "src/hack/GatekeeperTwoHack.sol";

contract GatekeeperTwoScript is Script {
    error HackFailed();

    function run() external {
        address gatekeeperTwoAddress = vm.envAddress("GATEKEEPER_TWO_ADDRESS");
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        vm.startBroadcast(attackerKey);
        new GatekeeperTwoHack(gatekeeperTwoAddress);
        vm.stopBroadcast();
    }
}
