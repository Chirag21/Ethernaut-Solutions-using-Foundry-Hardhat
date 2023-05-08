// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IPreservation} from "src/hack/interfaces/IPreservation.sol";
import {PreservationScript} from "script/16_PreservationScript.sol";

contract PreservationScriptTest is Test {
    function test_PreservationScriptTest() external {
        PreservationScript script = new PreservationScript();
        script.run();

        address preservationAddr = vm.envAddress("PRESERVATION_ADDRESS");
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        address newOwner = IPreservation(preservationAddr).owner();
        assertEq(newOwner, attacker, "Script Failed!!!");
    }
}
