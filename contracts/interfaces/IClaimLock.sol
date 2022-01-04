// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IClaimLock {
    struct LockedTradingReward {
        uint256 _locked;
        uint256 _lastClaimTime;
    }

    struct LockedFarmReward {
        uint256 _locked;
        uint256 _timestamp;
    }

    function lockFarmReward(address account, uint256 amount) external;
    function lockTradingReward(address account, uint256 amount) external;
    function claimFarmReward(uint256[] memory index) external;
    function claimTradingReward(address account) external;
    function getFarmAccInfo(address account) external view returns(LockedFarmReward[] memory lockedReward) ;
    function getClaimableFarmReward(address account, uint256 index) external view returns(uint256);
    function getTradingUnlockedReward(address account) external view returns(uint256 bonus);
    function getTradingLockedReward(address account) external view returns(uint256);

}