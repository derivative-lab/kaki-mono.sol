pragma solidity ^0.8.0;

import "../base/WithAdminRole.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IKakiGarden.sol";
import "../interfaces/IClaimLock.sol";

contract KakiGarden is IKakiGarden, WithAdminRole {
    // start mine block number
    uint256 public _startBlockNumber;
    // total allocation point
    uint256 public _totalAllocPoint;
    uint256 public _rewardPerBlock;

    IERC20 public _rewardToken;
    IClaimLock public _rewardLocker;
    mapping(address => uint256) public _poolId1; // poolId1 starting from 1,subtract 1 before using with poolInfo
    // Info of each user that stakes LP tokens. pid => user address => info
    mapping(uint256 => mapping(address => UserInfo)) public _userInfo;
    // Info of each pool.
    PoolInfo[] public _poolInfo;

    function initialize(
        IERC20 rewardToken,
        uint256 rewardPerBlock,
        uint256 startBlock
    ) public initializer {
        __WithAdminRole_init();
        _rewardToken = rewardToken;
        _rewardPerBlock = rewardPerBlock;
        _startBlockNumber = startBlock;
    }

    function setRewardLocker(IClaimLock rewardLocker) public restricted {
        _rewardLocker = rewardLocker;
    }

    function harvest(uint256 pid) public override {
        uint256 rAmount = _harvest(pid);

        if (rAmount > 0) {
            _rewardLocker.lockFarmReward(msg.sender, rAmount);
        }
        emit Harvest(msg.sender, pid, rAmount);
    }

    function harvestMany(uint256[] memory pids) public override {
        uint256 pl = pids.length;
        require(pl > 0, "empoty pids");

        uint256 rAmountTotal;
        uint256[] memory rAmounts = new uint256[](pl);
        for (uint256 i; i < pl; i++) {
            uint256 samount = _harvest(pids[i]);
            rAmountTotal += samount;
            rAmounts[i] = samount;
        }

        if (rAmountTotal > 0) {
            _rewardLocker.lockFarmReward(msg.sender, rAmountTotal);
        }
        emit HarvestMany(msg.sender, pids, rAmounts);
    }

    function _harvest(uint256 pid) internal returns (uint256 rAmount) {
        PoolInfo storage pool = _poolInfo[pid];
        UserInfo storage user = _userInfo[pid][msg.sender];
        if (user.amount > 0) {
            uint256 currentBlock = block.number;
            rAmount = (_rewardPerBlock * (currentBlock - user.rewardAtBlock) * pool.allocPoint) / _totalAllocPoint;
            user.rewardAtBlock = currentBlock;
        }
    }

    function version() public pure returns (uint256) {
        return 1;
    }
}
