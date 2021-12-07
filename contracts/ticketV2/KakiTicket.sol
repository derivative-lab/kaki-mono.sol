// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IkakiTicket.sol";
import "../base/BaseERC721.sol";
contract KakiTicket is IkakiTicket, BaseERC721 {

    mapping(uint256 => TicketPara) _ticketPara;

    function initialize() public initializer{
        __BaseERC721_init("", "");
    }

    function mint(
        address _to,
        uint256 _chip,
        uint256 _prob,
        uint256 _price,
        uint256 _type
    ) external override restricted returns (uint256 tokenId) {
        tokenId = totalMinted();
        _mint(_to, tokenId);
        _ticketPara[tokenId]._type = _type;
        _ticketPara[tokenId]._chip = _chip;
        _ticketPara[tokenId]._prob = _prob;
        increaceTokenId();
    }

    function getTicketMessage(uint256 tokenId) external override view returns (TicketPara memory) {
        return (_ticketPara[tokenId]);
    }
}