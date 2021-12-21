pragma solidity ^0.8.0;
import "../../interfaces/IBaseERC721.sol";
interface IKakiCaptain is IBaseERC721 {

    struct CapPara {
        uint256 captainType;
        uint256 memberNum;
        uint256 miningRate;
        uint256 combineRate;
        string capName;
    }


    function mint(
        address _to
    ) external returns (uint256 tokenId);

    function getCapType(uint256 tokenId) external view returns (uint256);
    function getCapInfo(uint256 tokenId) external view returns (CapPara[] memory capPara);
}