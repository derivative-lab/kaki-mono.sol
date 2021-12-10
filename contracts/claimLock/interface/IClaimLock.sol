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
        bool _claim;
    }

    function lockFarmReward(address account, uint256 amount) external;
    function lockTradingReward(address account, uint256 amount) external;
    function claimFarmRewardAll() external;
    function claimTradingReward(address account) external;
    function getClaimableFarmReward(address account) external view returns(uint256);
    function getTradingUnlockReward(address account) external view returns(uint256);
}