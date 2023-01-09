// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Privacy} from "src/levels/Privacy.sol";
import {PrivacyScript} from "script/12_PrivacyScript.sol";

contract PrivacyScriptTest is Test {
    function test_PrivacyScript() external {
        PrivacyScript script = new PrivacyScript();
        script.run();

        address privacyAddress = vm.envAddress("PRIVACY_ADDRESS");
        bool locked = Privacy(privacyAddress).locked();
        assertFalse(
            locked,
            "PrivacyScriptTest : Failed to unlock Privacy contract."
        );
    }
}
