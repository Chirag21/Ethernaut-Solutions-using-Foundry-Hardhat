// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Level as ReentranceFactory} from "src/levels/base/Level.sol";
import {IReentrance} from "src/hack/interfaces/IReentrance.sol";
import {ReentranceHack} from "src/hack/ReentranceHack.sol";

contract ReentranceTest is Test {
    ReentranceFactory private reentranceFactory;
    IReentrance private reentrance;
    ReentranceHack private reentranceHack;
    address private attacker = makeAddr("attacker");
    uint256 private constant INSERT_COIN = 0.001 ether;

    function setUp() external {
        // At the time of writing, Foundry does not support contract compilation if one of the contracts involved uses an older version of Solidity.
        // Hence, we deploy the contract using compiler generated creation code

        // Get the creation code and append the constructor arguments at the end
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("ReentranceFactory.sol")
        );

        address reentranceFactoryAddress;

        // This is the address at which runtime code is set, which will be executed on the chain.
        assembly {
            reentranceFactoryAddress := create(
                0,
                add(bytecode, 0x20),
                mload(bytecode)
            )
        }

        // Load ReentranceFactory contract instance using interface
        reentranceFactory = ReentranceFactory(reentranceFactoryAddress);

        // Create a level instance
        address reentranceAddress = reentranceFactory.createInstance{
            value: INSERT_COIN
        }(attacker);

        // Load Reentrance contract instance using interface
        reentrance = IReentrance(reentranceAddress);
        reentranceHack = new ReentranceHack(address(reentrance));
    }

    function test_ReentranceHack() external {
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        console2.log(
            "Reentrance Balance Before : ",
            address(reentrance).balance
        );

        reentranceHack.hack{value: INSERT_COIN}();

        console2.log(
            "Reentrance Balance After : ",
            address(reentrance).balance
        );

        bool success = reentranceFactory.validateInstance(
            payable(address(reentrance)),
            attacker
        );
        assertTrue(success, "Validation Failed!!!");

        vm.stopPrank();
    }
}
