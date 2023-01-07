// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IBuilding {
    function isLastFloor(uint) external returns (bool);
}
