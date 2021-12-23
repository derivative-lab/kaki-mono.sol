// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBlindBox {
    event BuyABox(address indexed account);
    event BuyBBox(address indexed account);

    function aBoxOpen() external;
    function bBoxOpen() external;
    function combine(uint256[3] memory ticket, uint256[] memory extraCap) external;
}
