// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {DelegationScript} from "script/6_DelegationScript.sol";
import {IDelegation} from "src/hack/interfaces/IDelegation.sol";

contract DelegationScriptTest is Test {
    function test_DelegationScript() external {
        DelegationScript script = new DelegationScript();
        script.run();

        address attacker = vm.envAddress("TESTNET_ADDRESS_1");
        address delegation = vm.envAddress("DELEGATION_ADDRESS");
        assertEq(
            attacker,
            IDelegation(delegation).owner(),
            "DelegationScriptTest : Failed to claim to ownership of the Delegation contract"
        );
    }
}
