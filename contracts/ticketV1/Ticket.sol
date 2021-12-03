// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract BlindBoxDrop is ERC721, Ownable {
    constructor() ERC721("", "") public {}

    function mint(address _to, uint _tokenId, string calldata _uri) external override onlyOwner{
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
    }
}