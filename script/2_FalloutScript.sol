// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface IFallout {
    function Fal1out() external payable;

    function owner() external view returns (address);
}

contract FalloutScript is Script {
    function run() external {
        IFallout fallout = IFallout(vm.envAddress("FALLOUT_ADDRESS"));
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);
        fallout.Fal1out();
        vm.stopBroadcast();
    }
}
