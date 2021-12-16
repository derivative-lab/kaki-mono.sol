pragma solidity ^0.8.0;

interface IKakiNoLoss {
    event CreateFaction(address indexed account, uint256 factionId, uint256 time);
    event JoinFaction(address indexed account, uint256 factionId,uint256 id,uint256 amount, uint256 time);
    event AddStake(address indexed account, uint256 factionId,uint256 id,uint256 amount);
    event LeaveFaction(address indexed account,uint256 factionId,uint256 bonus);
    event Fire(address indexed account,uint256 chapter, uint256 lastRound, uint256 factionId,uint256 amount,bool binary, uint256 time);
    event ClaimBonus(address indexed account,uint256 bonus,uint256 time);
}