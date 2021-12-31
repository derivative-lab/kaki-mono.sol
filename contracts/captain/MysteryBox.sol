// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IMysteryBox.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MysteryBox is IMysteryBox, Ownable, ERC721Enumerable{
    uint256 public _tokenId;
    uint256 public _maximum;
    string _baseTokenURI;

    constructor(string memory baseURI) ERC721("Kakier Seed Box", "KSD") public {
        setBaseURI(baseURI);
        _maximum = 1010;
    }

    function mint(address _to) public override onlyOwner {
        require(_maximum - _tokenId != 0, "Reach the upper limit.");
        _mint(_to, _tokenId);
        _tokenId ++;
    }

    //*************************** admin ********************************** */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

}