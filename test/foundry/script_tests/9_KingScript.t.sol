// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {KingScript} from "script/9_KingScript.sol";

interface IKing {
    function _king() external view returns (address);
}

contract KingScriptTest is Test {
    function test_KingScript() external {
        KingScript script = new KingScript();

        // New king
        address kingHackAddress = script.run();

        address kingAddress = vm.envAddress("KING_ADDRESS");
        IKing king = IKing(kingAddress);

        assertEq(
            kingHackAddress,
            king._king(),
            "KingScriptTest : Failed to set KingHack as the new king"
        );
    }
}
