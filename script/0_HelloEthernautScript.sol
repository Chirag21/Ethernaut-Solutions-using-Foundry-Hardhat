//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";

interface IInstance {
    function password() external view returns (string memory);

    function authenticate(string memory) external;
}

contract HackHelloEthernautScript is Script {
    function run() external {
        IInstance instance = IInstance(
            vm.envAddress("HELLO_ETHERNAUT_ADDRESS")
        );
        uint256 deployerPrivatekey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivatekey);
        string memory password = instance.password();
        instance.authenticate(password);
        vm.stopBroadcast();
    }
}
