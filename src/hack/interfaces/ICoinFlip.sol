// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ICoinFlip {
    function consecutiveWins() external view returns (uint256);

    function flip(bool) external returns (bool);

    function FACTOR() external view returns (uint256);
}
