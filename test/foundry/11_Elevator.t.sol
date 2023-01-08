// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ElevatorFactory} from "src/levels/ElevatorFactory.sol";
import {Elevator} from "src/levels/Elevator.sol";
import {ElevatorHack} from "src/hack/ElevatorHack.sol";

contract ElevatorTest is Test {
    ElevatorFactory private elevatorFactory;
    Elevator private elevator;
    ElevatorHack private elevatorHack;
    address private attacker = makeAddr("attacker");

    function setUp() external {
        elevatorFactory = new ElevatorFactory();
        address elevatorAddress = elevatorFactory.createInstance(attacker);
        elevator = Elevator(elevatorAddress);
    }

    function test_ElevatorHack() external {
        console2.log("top : ", elevator.top());

        elevatorHack = new ElevatorHack();
        elevatorHack.hack(address(elevator));
        bool success = elevatorFactory.validateInstance(
            payable(address(elevator)),
            attacker
        );

        console2.log("top : ", elevator.top());

        assertTrue(success, "FAILED!!!");
    }
}
