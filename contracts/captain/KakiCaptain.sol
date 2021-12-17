// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IKakiCaptain.sol";
import "../base/BaseERC721.sol";
contract KakiCaptain is IKakiCaptain, BaseERC721 {

    mapping(uint256 => TicketPara) _ticketPara;

    function initialize() public initializer{
        __BaseERC721_init("", "");
    }

    //uint256 _captainType,
    // uint256 _memberNum,
    // uint256 _miningRate,
    // uint256 _combineRate

    function mint(
        address _to
    ) external override restricted returns (uint256 tokenId) {
        tokenId = totalMinted();
        _ticketPara[tokenId].captainType = _captainType;
        _ticketPara[tokenId].memberNum = _memberNum;
        _ticketPara[tokenId].miningRate = _miningRate;
        _ticketPara[tokenId].combineRate = _combineRate;
        _mint(_to, tokenId);
        increaceTokenId();
    }

    function getTicketMessage(uint256 tokenId) external override view returns (TicketPara memory) {
        return (_ticketPara[tokenId]);
    }
}