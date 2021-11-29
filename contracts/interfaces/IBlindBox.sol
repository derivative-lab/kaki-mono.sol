// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBlindBox {
    struct Prob {
        uint256 _type;
        uint256 _chip;
        uint256 _probability;
    }

    event BuyABox(address indexed account);
    event BuyBBox(address indexed account);

    function aBoxOpen() external;
    function bBoxOpen() external;
    function combine(uint256[3] memory ticket, uint256 extraCap) external;
    function getTicketMessage(uint256 tokenId) external view returns(Prob memory);
}