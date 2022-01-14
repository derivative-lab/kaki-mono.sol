// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IMysteryBox.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract MysteryBox is IMysteryBox, Ownable, ERC721Enumerable{
    using Strings for uint256;
    uint256 public _tokenId;
    //uint256 public _maximum;
    string _tokenURI;

    constructor(string memory baseURI) ERC721("Kakier Seed Box", "KSB") public {
        _tokenURI = baseURI;
        //_maximum = 800;
    }

    function mint(address _to) public override onlyOwner {
        //require(_tokenId < _maximum, "Reach the upper limit.");
        _safeMint(_to, _tokenId);
        _tokenId ++;
    }

    function batchMint(address _to, uint256 num) public override onlyOwner {
        //require(_tokenId < _maximum, "Reach the upper limit.");
        for(uint256 i; i < num; i++) {
            _safeMint(_to, _tokenId);
            _tokenId ++;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        return _tokenURI;
    }

    //*************************** admin ********************************** */
    function setTokenURI(string memory baseURI) public onlyOwner {
        _tokenURI = baseURI;
    }

}