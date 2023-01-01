// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IReentrance {
    function donate(address) external payable;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;
}
