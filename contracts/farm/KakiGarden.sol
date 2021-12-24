pragma solidity ^0.8.0;

import "../base/WithAdminRole.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IKakiGarden.sol";
import "../interfaces/IClaimLock.sol";
import {DebtToken} from "./DebtToken.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract KakiGarden is IKakiGarden, WithAdminRole, ReentrancyGuardUpgradeable {
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
        __ReentrancyGuard_init();
        _rewardToken = rewardToken;
        _rewardPerBlock = rewardPerBlock;
        _startBlockNumber = startBlock;
    }

    function setRewardLocker(IClaimLock rewardLocker) public restricted {
        _rewardLocker = rewardLocker;
    }

    function addPool(
        uint256 allocPoint,
        IERC20 token,
        string memory name
    ) public restricted {
        require(_poolId1[address(token)] == 0, "addPool: token is already in pool");

        uint256 pl = _poolInfo.length;
        _poolId1[address(token)] = pl + 1;

        _poolInfo.push(
            PoolInfo({
                allocPoint: allocPoint,
                pid: pl,
                stakingAmount: 0,
                token: token,
                debtToken: new DebtToken(
                    string(abi.encodePacked("k-", token.name())),
                    string(abi.encodePacked("k-", token.symbol()))
                ),
                name: name
            })
        );
        _totalAllocPoint += allocPoint;
    }

    function deposit(uint256 pid, uint256 amount) public override nonReentrant {
        uint256 currentBlock = block.number;
        require(currentBlock >= _startBlockNumber, "not begin yet");
        UserInfo storage user = _userInfo[pid][msg.sender];
        if (user.amount > 0) {
            _harvest(pid);
        }
        user.rewardAtBlock = currentBlock;
        PoolInfo storage poolInfo = _poolInfo[pid];
        poolInfo.token.transferFrom(msg.sender, address(this), amount);
        user.amount += amount;
        poolInfo.stakingAmount += amount;
        poolInfo.debtToken.mint(msg.sender, amount);
        emit Deposit(msg.sender, pid, amount);
    }

    function withdraw(uint256 pid, uint256 amount) public override nonReentrant {
        _withdraw(pid, amount);
    }

    function _withdraw(uint256 pid, uint256 amount) internal {
        require(amount > 0, "amount cannot be zero");
        UserInfo storage user = _userInfo[pid][msg.sender];
        require(user.amount >= amount, "out of balance");
        _harvest(pid);
        PoolInfo storage poolInfo = _poolInfo[pid];
        poolInfo.token.transfer(msg.sender, amount);
        poolInfo.debtToken.burn(msg.sender, amount);
        user.amount -= amount;
        poolInfo.stakingAmount -= amount;
        emit Withdraw(msg.sender, pid, amount);
    }

    function harvest(uint256 pid) public override nonReentrant {
        _harvest(pid);
    }

    function _harvest(uint256 pid) internal {
        uint256 rAmount = onlyHarvest(pid);

        if (rAmount > 0) {
            _rewardLocker.lockFarmReward(msg.sender, rAmount);
        }
        emit Harvest(msg.sender, pid, rAmount);
    }

    function harvestMany(uint256[] memory pids) public override nonReentrant {
        uint256 pl = pids.length;
        require(pl > 0, "empoty pids");

        uint256 rAmountTotal;
        uint256[] memory rAmounts = new uint256[](pl);
        for (uint256 i; i < pl; i++) {
            uint256 samount = onlyHarvest(pids[i]);
            rAmountTotal += samount;
            rAmounts[i] = samount;
        }

        if (rAmountTotal > 0) {
            _rewardLocker.lockFarmReward(msg.sender, rAmountTotal);
        }
        emit HarvestMany(msg.sender, pids, rAmounts);
    }

    function onlyHarvest(uint256 pid) internal returns (uint256 rAmount) {
        PoolInfo storage pool = _poolInfo[pid];
        UserInfo storage user = _userInfo[pid][msg.sender];
        if (user.amount > 0) {
            uint256 currentBlock = block.number;
            rAmount = (_rewardPerBlock * (currentBlock - user.rewardAtBlock) * pool.allocPoint) / _totalAllocPoint;
            user.rewardAtBlock = currentBlock;
        }
    }

    function poolInfoLength() public view returns (uint256) {
        return _poolInfo.length;
    }

    function version() public pure returns (uint256) {
        return 1;
    }
}
