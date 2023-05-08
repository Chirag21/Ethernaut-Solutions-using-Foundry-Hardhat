// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IPreservation {
    function setFirstTime(uint256 _timeStamp) external;

    function owner() external view returns (address);
}
