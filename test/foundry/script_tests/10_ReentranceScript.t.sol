// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ReentranceScript} from "script/10_ReentranceScript.sol";

contract ReentranceScriptTest is Test {
    function test_ReentranceScript() external {
        ReentranceScript reentranceScript = new ReentranceScript();
        reentranceScript.run();

        address reentranceAddress = vm.envAddress("REENTRANCE_ADDRESS");
        uint balance = reentranceAddress.balance;
        assertEq(
            balance,
            0,
            "ReentranceScriptTest : Failed to drain Reentrance contract"
        );
    }
}
