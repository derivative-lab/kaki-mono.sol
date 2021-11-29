pragma solidity ^0.8.0;

interface IkakiTicket {
    function mint(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external;

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns(address);
}
