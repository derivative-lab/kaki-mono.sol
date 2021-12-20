// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaptainClaim {
    event Claim(address indexed account);
    event Mint(address indexed account);


    function claim() external;
    function mint() external payable;
}