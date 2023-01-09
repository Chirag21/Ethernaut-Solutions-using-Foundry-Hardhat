// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ForceScript} from "script/7_ForceScript.sol";

contract ForceScriptTest is Test {
    function test_ForceScript() external {
        ForceScript script = new ForceScript();
        script.run();

        address forceAddress = vm.envAddress("FORCE_ADDRESS");
        assertGt(
            forceAddress.balance,
            0,
            "ForceScriptTest : Failed to send ether to Force contract"
        );
    }
}
