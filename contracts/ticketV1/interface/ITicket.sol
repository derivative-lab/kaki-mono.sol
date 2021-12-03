// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITicket {
    function mint(address _to, uint _tokenId, string calldata _uri) external; 
}