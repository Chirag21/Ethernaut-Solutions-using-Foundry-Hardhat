// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {NaughtCoin} from "src/levels/NaughtCoin.sol";
import {NaughtCoinScript} from "script/15_NaughtCoinScript.sol";

contract NaughtCoinScriptTest is Test {
    function test_NaughtCoinScriptTest() external {
        NaughtCoinScript naughtCoinScript = new NaughtCoinScript();
        naughtCoinScript.run();

        address naughtCoinAddr = address(
            uint160(vm.envUint("NAUGHT_COIN_ADDRESS"))
        );
        NaughtCoin naughtCoin = NaughtCoin(naughtCoinAddr);
        address attacker = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        assertEq(naughtCoin.balanceOf(attacker), 0, "Script Failed!!!");
    }
}
