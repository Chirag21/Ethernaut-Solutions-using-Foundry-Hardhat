// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {GatekeeperTwo} from "src/levels/GatekeeperTwo.sol";
import {GatekeeperTwoScript} from "script/14_GatekeeperTwoScript.sol";
import {GatekeeperTwoHack} from "src/hack/GatekeeperTwoHack.sol";

contract GatekeeperTwoScriptTest is Test {
    function test_GatekeeperTwoScript() external {
        GatekeeperTwoScript script = new GatekeeperTwoScript();
        script.run();

        address attacker = vm.envAddress("TESTNET_ADDRESS_1");

        address gatekeeperTwoAddr = vm.envAddress("GATEKEEPER_TWO_ADDRESS");
        assertEq(
            attacker,
            GatekeeperTwo(gatekeeperTwoAddr).entrant(),
            "GatekeeperTwoScriptTest : Script Failed. Entrant not set."
        );
    }
}
