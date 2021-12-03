// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenBox {
    struct TicketPara {
        bool isDrop;
        uint256 invalidTime;
    }

    function claim() external;
    function buyTicket() external;
    function sendToPool() external;
    function getTicketMessage(uint256 tokenId) external view returns(TicketPara memory);
}