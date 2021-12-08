// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenBox {
    function claim() external;
    function buyTicket(uint256 num) external;
}