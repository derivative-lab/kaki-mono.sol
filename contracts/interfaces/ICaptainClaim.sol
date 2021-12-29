// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaptainClaim {
    //event Claim(address indexed account, uint256 tokenId);
    event Mint(address indexed account, uint256 tokenId);

    //function claim() external;
    function mint() external payable;
    function switchByBox(uint256 boxId) external;
}