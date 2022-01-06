pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/ math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./MockAlpacaToken.sol";
import "../interfaces/IFairLaunch.sol";

contract MockFairLaunch is IFairLaunch {
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many Staking tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 bonusDebt; // Last block that user exec something to the pool.
        address fundedBy; // Funded by who?
    }

    struct PoolInfo {
        address stakeToken; // Address of Staking token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ALPACAs to distribute per block.
        uint256 lastRewardBlock; // Last block number that ALPACAs distribution occurs.
        uint256 accAlpacaPerShare; // Accumulated ALPACAs per share, times 1e12. See below.
        uint256 accAlpacaPerShareTilBonusEnd; // Accumated ALPACAs per share until Bonus End.
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    MockAlpacaToken public _alpaca;
    IERC20[] public _stakeTokens;

    //  ILocker[] public _lockers;
    uint256 private constant ACC_ALPACA_PRECISION = 1e12;

    mapping(uint256 => mapping(address => UserInfo)) public _userInfo;
    uint256 _totalAllocPoint;
    PoolInfo[] public _poolInfo;
    uint256 public _startBlock;
    uint256 public _alpacaPerBlock;

    constructor(
        MockAlpacaToken alpaca,
        uint256 alpacaPerBlock,
        uint256 startBlock // uint256 _bonusLockupBps // uint256 _bonusEndBlock
    ) public {
        _alpaca = alpaca;
        _alpacaPerBlock = alpacaPerBlock;
        _startBlock = startBlock;
        // bonusMultiplier = 0;
        _totalAllocPoint = 0;
        alpaca = _alpaca;
        // bonusLockUpBps = _bonusLockupBps;
        // bonusEndBlock = _bonusEndBlock;
    }

    function poolLength() public view override returns (uint256) {
        return _poolInfo.length;
    }

    function addPool(
        uint256 allocPoint,
        address stakeToken,
        bool withUpdate
    ) public {
        if (withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        _totalAllocPoint += allocPoint;
        _poolInfo.push(
            PoolInfo({
                allocPoint: allocPoint,
                lastRewardBlock: lastRewardBlock,
                accAlpacaPerShare: 0,
                stakeToken: stakeToken,
                accAlpacaPerShareTilBonusEnd: 0
            })
        );
    }

    function setPool(
        uint256 _pid,
        uint256 allocPoint,
        bool _withUpdate
    ) public override {
        massUpdatePools();
        _totalAllocPoint = _totalAllocPoint - _poolInfo[_pid].allocPoint + allocPoint;
        _poolInfo[_pid].allocPoint = allocPoint;
    }

    function pendingAlpaca(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage poolInfo = _poolInfo[_pid];
        UserInfo storage userInfo = _userInfo[_pid][_user];
        uint256 accAlpacaPerShare = poolInfo.accAlpacaPerShare;
        uint256 stakingSupply = IERC20(poolInfo.stakeToken).balanceOf(address(this));

        if (block.number > poolInfo.lastRewardBlock && stakingSupply > 0) {
            uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
            uint256 alpacaReward = (multiplier * _alpacaPerBlock * poolInfo.allocPoint) / _totalAllocPoint;
            accAlpacaPerShare = (accAlpacaPerShare + alpacaReward * 1e12) / stakingSupply;
        }
        return (userInfo.amount * accAlpacaPerShare) / 1e12 - userInfo.rewardDebt;
    }

    function updatePool(uint256 _pid) public override {
        PoolInfo storage pool = _poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = IERC20(pool.stakeToken).balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 alpacaReward = (multiplier * _alpacaPerBlock * pool.allocPoint) / _totalAllocPoint;

        _alpaca.mint(address(this), alpacaReward);
        pool.accAlpacaPerShare = (pool.accAlpacaPerShare + alpacaReward * 1e12) / lpSupply;

        // if (block.number <= bonusEndBlock) {
        // _alpaca.lock(devaddr, alpacaReward*(bonusLockUpBps).div(100000));
        // pool.accAlpacaPerShareTilBonusEnd = pool.accAlpacaPerShare;
        // }
        // if (block.number > bonusEndBlock && pool.lastRewardBlock < bonusEndBlock) {
        //     uint256 alpacaBonusPortion = bonusEndBlock
        //         .sub(pool.lastRewardBlock)
        //         .mul(bonusMultiplier)
        //         .mul(alpacaPerBlock)
        //         .mul(pool.allocPoint)
        //         .div(totalAllocPoint);
        //     alpaca.lock(devaddr, alpacaBonusPortion.mul(bonusLockUpBps).div(100000));
        //     pool.accAlpacaPerShareTilBonusEnd = pool.accAlpacaPerShareTilBonusEnd.add(
        //         alpacaBonusPortion.mul(1e12).div(lpSupply)
        //     );
        // }
        pool.lastRewardBlock = block.number;
    }

    function deposit(
        address for_,
        uint256 pid,
        uint256 amount
    ) public override {
        PoolInfo storage pool = _poolInfo[pid];
        UserInfo storage user = _userInfo[pid][for_];

        updatePool(pid);
        if (user.amount > 0) _harvest(for_, pid);
        if (user.fundedBy == address(0)) user.fundedBy = msg.sender;
        IERC20(pool.stakeToken).transferFrom(address(msg.sender), address(this), amount);
        user.amount = user.amount + amount;
        user.rewardDebt = (user.amount * pool.accAlpacaPerShare) / 1e12;
        user.bonusDebt = (user.amount * pool.accAlpacaPerShareTilBonusEnd) / 1e12;
        emit Deposit(msg.sender, pid, amount);
    }

    function withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) public override {
        _withdraw(_for, _pid, _amount);
    }

    function withdrawAll(address _for, uint256 _pid) public override {
        _withdraw(_for, _pid, _userInfo[_pid][_for].amount);
    }

    function _withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) internal {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_for];
        require(user.fundedBy == msg.sender, "only funder");
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        _harvest(_for, _pid);
        user.amount = user.amount - _amount;
        user.rewardDebt = (user.amount * pool.accAlpacaPerShare) / 1e12;
        user.bonusDebt = (user.amount * pool.accAlpacaPerShareTilBonusEnd) / 1e12;
        if (user.amount == 0) user.fundedBy = address(0);
        if (pool.stakeToken != address(0)) {
            IERC20(pool.stakeToken).transfer(address(msg.sender), _amount);
        }
        emit Withdraw(msg.sender, _pid, user.amount);
    }

    function harvest(uint256 _pid) public override {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][msg.sender];
        updatePool(_pid);
        _harvest(msg.sender, _pid);
        user.rewardDebt = (user.amount * pool.accAlpacaPerShare) / 1e12;
        user.bonusDebt = (user.amount * pool.accAlpacaPerShareTilBonusEnd) / 1e12;
    }

    function _harvest(address _to, uint256 _pid) internal {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_to];
        require(user.amount > 0, "nothing to harvest");
        uint256 pending = (user.amount * pool.accAlpacaPerShare) / 1e12 - user.rewardDebt;
        require(pending <= _alpaca.balanceOf(address(this)), "wtf not enough alpaca");
        uint256 bonus = (user.amount * pool.accAlpacaPerShareTilBonusEnd) / 1e12 - user.bonusDebt;
        safeAlpacaTransfer(_to, pending);
        // _alpaca.lock(_to, bonus.mul(bonusLockUpBps).div(10000));
    }

    function massUpdatePools() public {
        uint256 length = _poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _lastRewardBlock, uint256 _currentBlock) public view returns (uint256) {
        // if (_currentBlock <= bonusEndBlock) {
        //     return (_currentBlock - _lastRewardBlock) * (bonusMultiplier);
        // }
        // if (_lastRewardBlock >= bonusEndBlock) {
        //     return _currentBlock - _lastRewardBlock;
        // }
        // // This is the case where bonusEndBlock is in the middle of _lastRewardBlock and _currentBlock block.
        // return (bonusEndBlock - _lastRewardBlock) * bonusMultiplier + (_currentBlock - bonusEndBlock);

        return _currentBlock - _lastRewardBlock;
    }

    function safeAlpacaTransfer(address _to, uint256 _amount) internal {
        uint256 alpacaBal = _alpaca.balanceOf(address(this));
        if (_amount > alpacaBal) {
            require(_alpaca.transfer(_to, alpacaBal), "failed to transfer ALPACA");
        } else {
            require(_alpaca.transfer(_to, _amount), "failed to transfer ALPACA");
        }
    }
}
