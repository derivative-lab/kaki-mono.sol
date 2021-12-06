// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITicket {

    struct TicketPara {
        bool isDrop;
        uint256 invalidTime;
    }

    function mint(
        address _to, 
        bool _isDrop, 
        uint256 _invalidTime
        ) 
        external 
        returns (uint256 tokenId);
    
    function getTicketMessage(uint256 tokenId) external view returns (TicketPara memory);
}