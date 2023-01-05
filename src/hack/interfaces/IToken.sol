// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IToken {
    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);
}
