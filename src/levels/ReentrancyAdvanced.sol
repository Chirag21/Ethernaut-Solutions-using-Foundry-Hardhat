// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Reentrance {
    mapping(address depositor => uint256 balance) public balances;

    constructor() payable {
        deposit();
    }

    function withdraw(uint amount) external {
        require(amount > 0, "Can't withdraw zero");
        require(balances[msg.sender] >= amount, "Not enough funds");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Low level call failed");
        balances[msg.sender] -= amount;
    }

    function deposit() public payable {
        assembly {
            let location := keccak256(balances.slot, caller())
            let amount := add(sload(location), callvalue())
            sstore(location, amount)
        }

        //balances[msg.sender] += msg.value;
    }

    receive() external payable {
        deposit();
    }
}
