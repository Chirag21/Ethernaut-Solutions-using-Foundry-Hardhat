// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IPuzzleWallet {
    function owner() external view returns (address);

    function whitelisted(address _whiteListed) external view returns (bool);

    function addToWhitelist(address addr) external;

    function setMaxBalance(uint256 _maxBalance) external;

    function multicall(bytes[] calldata data) external payable;

    function deposit() external payable;

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable;
}

interface IPuzzleWalletProxy {
    function proposeNewAdmin(address _newAdmin) external;

    function admin() external view returns (address);

    function pendingAdmin() external view returns (address);
}
