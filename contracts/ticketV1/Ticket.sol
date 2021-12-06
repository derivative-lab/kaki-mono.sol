// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../base/BaseERC721.sol";
import "./interface/ITicket.sol";

contract BlindBoxDrop is BaseERC721, ITicket {
    mapping(uint256 => TicketPara) _ticketIsDrop;

    function initialize() public initializer {
        __BaseERC721_init("", "");
    }

    function mint(
        address _to,
        bool _isDrop,
        uint256 _invalidTime
    ) external override restricted returns (uint256 tokenId) {
        tokenId = totalMinted();
        _mint(_to, tokenId);
        _ticketIsDrop[tokenId].isDrop = _isDrop;
        _ticketIsDrop[tokenId].invalidTime = _invalidTime;
        increaceTokenId();
    }

    function getTicketMessage(uint256 tokenId) public view override returns (TicketPara memory) {
        return (_ticketIsDrop[tokenId]);
    }

    function version() public pure returns (uint256) {
        return 1;
    }
}
