// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {GatekeeperOne} from "src/levels/GatekeeperOne.sol";
import {GatekeeperOneScript} from "script/13_GatekeeperOneScript.sol";
import {GatekeeperOneHack} from "src/hack/GatekeeperOneHack.sol";

contract GatekeeperOneScriptTest is Test {
    function test_GatekeeperOneScript() external {
        GatekeeperOneScript script = new GatekeeperOneScript();
        script.run();

        address attacker = vm.envAddress("TESTNET_ADDRESS_1");

        address gatekeeperOneAddr = vm.envAddress("GATEKEEPER_ONE_ADDRESS");
        assertEq(
            attacker,
            GatekeeperOne(gatekeeperOneAddr).entrant(),
            "GatekeeperOneScriptTest : Script Failed. Entrant not set."
        );
    }
}
