// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IElevator {
    function top() external view returns (bool);

    function goTo(uint) external;
}
