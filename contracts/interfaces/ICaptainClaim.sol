// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaptainClaim {
    //event Claim(address indexed account, uint256 tokenId);
    event Mint(address indexed account, uint256 tokenId);

    //function claim() external;
    function mint() external payable;
    function switchByBox(uint256 boxId) external;
    function getList() external view returns(uint256[] memory idList);
    function getTotalMint() external view returns(uint256 count);
}