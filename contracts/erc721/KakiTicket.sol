// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IkakiTicket.sol";
import "../base/BaseERC721.sol";
contract KakiTicket is  IkakiTicket ,BaseERC721{
    address buyTicketAdd;

    modifier onlyClaimAdd() {
        require(msg.sender == buyTicketAdd, "invalid address.");
        _;
    }

    function initialize() public initializer{
        __BaseERC721_init("", "");
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri
    ) external onlyClaimAdd {
        _mint(_to, _tokenId);
        // super._setTokenURI(_tokenId, _uri);
    }

    function setCapClaimAdd(address claimAdd) public onlyOwner {
        buyTicketAdd = claimAdd;
    }
}
