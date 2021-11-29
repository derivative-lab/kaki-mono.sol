import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

interface IBaseERC721 is IERC721EnumerableUpgradeable {
    function totalMinted() external view returns (uint256);

    function batchTransfer(address[] memory to, uint256[] memory tokenIds) external;

    function batchTransferSame(address to, uint256[] memory tokenIds) external;

    function tokensOfOwner(address _owner) external view returns (uint256[] memory);

    function burn(uint256 tokenId) external;
}
