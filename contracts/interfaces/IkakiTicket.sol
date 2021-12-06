pragma solidity ^0.8.0;
import "./IBaseERC721.sol";
interface IkakiTicket is IBaseERC721{

    struct TicketPara {
        bool _type;
        uint256 _chip;
        uint256 _prob;
    }

    function mint(
        address _to, 
        bool _isDrop, 
        uint256 _invalidTime
        ) 
        external 
        returns (uint256 tokenId);

    function getTicketMessage(uint256 tokenId) external view returns (TicketPara memory);
}
