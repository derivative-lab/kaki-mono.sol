// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IKakiCaptain.sol";
import "../base/BaseERC721.sol";
contract KakiCaptain is IKakiCaptain, BaseERC721 {

    uint256 public lowMember;
    uint256 public mediumMember;
    uint256 public highMember;
    uint256 public kRate;
    uint256 public lowCombineRate;
    uint256 public mediumCombineRate;
    uint256 public highCombineRate;
    mapping(uint256 => TicketPara) _ticketPara;

    function initialize() public initializer{
        __BaseERC721_init("", "");
    }

    function mint(
        address _to
    ) external override restricted returns (uint256 tokenId) {
        uint256 tokenIdex = totalMinted();
        require(tokenIdex < 2020, "Reach the upper limit.");
        _mint(_to, tokenId);
        increaceTokenId();
    }

    function getTicketMessage(uint256 tokenId) external override view returns (TicketPara memory) {
        

        return (_ticketPara[tokenId]);
    }
}