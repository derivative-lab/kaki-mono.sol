pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

interface IkakiTicket is IERC721EnumerableUpgradeable {


    function mint(
        address to,
        uint tokenId,
        string calldata uri
    ) external;

    // function totalMinted() external view returns (uint256);

    // function batchTransfer(address[] memory to, uint256[] memory tokenIds) external;

    // // function version() external pure returns (uint256);

    // function setBaseTokenURI(string memory baseURI_) external;

    // function tokensOfOwner(address _owner) external view returns (uint256[] memory);

}
