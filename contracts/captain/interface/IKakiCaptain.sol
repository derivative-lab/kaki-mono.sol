pragma solidity ^0.8.0;
import "../../interfaces/IBaseERC721.sol";
interface IKakiCaptain is IBaseERC721 {

    struct TicketPara {
        uint256 captainType;
        uint256 memberNum;
        uint256 miningRate;
        uint256 combineRate;
    }


    function mint(
        address _to
    ) external returns (uint256 tokenId);

    function getTicketMessage(uint256 tokenId) external view returns (TicketPara memory);
}