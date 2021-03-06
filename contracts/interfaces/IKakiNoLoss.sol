pragma solidity ^0.8.0;

interface IKakiNoLoss {
    struct FactionListVO {
        address _captain;
        uint256 _id;
        uint256 _members;
        uint256 _winFireCnt;
        uint256 _totalFireCnt;
        uint256 _totalBonus;
        uint256 _nftId;
        uint256 _usedkc;
        uint256 _totalkc;
        uint256[10] _stakeAmount;
        uint256[10] _captionStakeAmount;
    }

    struct CurrentChapterBonusVO {
        uint256 _spaceShipBonus;
        uint256 _captionBonus;
        uint256 _crewBonus;
        uint256 _myBonus;
    }

    event CreateFaction(address indexed account, uint256 factionId, uint256 nftId, uint256 time);
    event JoinFaction(address indexed account, uint256 factionId, uint256 tokenIndex, uint256 amount, uint256 time);
    event AddStake(address indexed account, uint256 factionId, uint256 tokenIndex, uint256 amount, uint256 time);
    event LeaveFaction(address indexed account, uint256 factionId, uint256 bonus, uint256 time);
    event Fire(
        address indexed account,
        uint256 chapter,
        uint256 lastRound,
        uint256 factionId,
        uint256 amount,
        bool binary,
        uint256 time
    );
    event ClaimBonus(address indexed account, uint256 bonus, uint256 time);

    event AddLoot(uint256 chapter, uint256 interest, uint256 nftInterest, uint256 time);
    event BattleDamage(uint256 chapter, uint256 lastRound, uint256 startAnswer, uint256 endAnswer, uint256 time);

    function createFaction(uint256 nftId) external;

    function joinFaction(
        uint256 factionId,
        uint256 tokenIndex,
        uint256 amount
    ) external;

    function addStake(
        uint256 factionId,
        uint256 tokenIndex,
        uint256 amount
    ) external;

    function leaveFaction(uint256 factionId) external;

    function fire(
        uint256 factionId,
        uint256 amount,
        bool binary
    ) external;

    function claimBonus() external returns (uint256);

    function updateBonus() external returns (uint256);

    function getFactionList() external view returns (FactionListVO[] memory listVo);

    function getFactionData(uint256 factionId) external view returns (FactionListVO memory vo);

    function getCurrentChapterBonus(uint256 factionId)
        external
        view
        returns (CurrentChapterBonusVO memory bonus1, CurrentChapterBonusVO memory bonus2);

    function getRoundStartTime(uint256 chapter, uint256 round) external view returns (uint256);

    function getRoundPrice(uint256 chapter, uint256 round) external view returns (uint256, uint256);
}
