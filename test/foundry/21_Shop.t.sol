// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Shop} from "src/levels/Shop.sol";
import {ShopFactory} from "src/levels/ShopFactory.sol";
import {ShopHack} from "src/hack/ShopHack.sol";

contract ShopTest is Test {
    Shop private shop;
    ShopFactory private factory;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        factory = new ShopFactory();
        vm.startPrank(attacker, attacker);
        address shopAddress = factory.createInstance(attacker);
        shop = Shop(shopAddress);
    }

    function test_ShopHack() external {
        vm.startPrank(address(shop), attacker);
        uint256 initialPrice = shop.price();

        ShopHack shopHack = new ShopHack(address(shop));
        shopHack.hack();

        uint256 newPrice = shop.price();
        assertTrue(newPrice < initialPrice, "Hack Failed!!!");

        bool success = factory.validateInstance(
            payable(address(shop)),
            attacker
        );
        assertTrue(success, "Failed To Validate The Instance!!!");
        vm.stopPrank();
    }
}
