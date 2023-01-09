// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ElevatorScript} from "script/11_ElevatorScript.sol";
import {IElevator} from "src/hack/interfaces/IElevator.sol";

contract ElevatorScriptTest is Test {
    function test_ElevatorScript() external {
        ElevatorScript script = new ElevatorScript();
        script.run();

        address elevatorAddress = vm.envAddress("ELEVATOR_ADDRESS");
        IElevator elevator = IElevator(elevatorAddress);
        bool top = elevator.top();

        assertTrue(top, "ElevatorScriptTest : Setting the top to true failed.");
    }
}
