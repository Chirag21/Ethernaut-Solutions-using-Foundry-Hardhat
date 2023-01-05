// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ITelephone {
    function changeOwner(address) external;

    function owner() external view returns (address);
}
