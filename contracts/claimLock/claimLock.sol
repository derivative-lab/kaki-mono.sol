pragma solidity ^0.8.0;
import "../interfaces/IClaimLock.sol";
import "../interfaces/IKaki.sol";
import "../base/WithRandom.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IERC20.sol";

contract ClaimLock is IClaimLock, WithAdminRole {
    IKaki  _kaki;
    uint256 constant THOUSAND = 10 ** 3;
    uint256 public _startTime;
    uint256 public _tradingStartTime;
    uint256 public _farmPeriod;
    uint256 public _tradingPeriod;
    uint256 public _farmRate;
    address public _addFarm;
    address public _addTrading;
    
    bool internal locked;

    mapping(address => LockedTradingReward) public _userLockedTradeRewards;
    mapping(address => LockedFarmReward[]) public _userLockedFarmRewards;
    mapping(address => uint256) public _userFarmLockedAmount;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier isFarm() {
        require(msg.sender == _addFarm, "Invalid address.");
        _;
    }

    modifier isTrading() {
        require(msg.sender == _addTrading, "Invalid address.");
        _;
    }

    function initialize(address farmAdd, IKaki kTokenAdd) public initializer {
        __WithAdminRole_init();
        _farmPeriod = 7776000;
        _tradingPeriod = 31104000;
        _tradingStartTime = 31104000; //trading start time !!!!
        _addFarm = farmAdd;
        _kaki = kTokenAdd;
        _farmRate = 500;
    }

    function lockFarmReward(address account, uint256 amount) public override isFarm {
        uint256 currentTimestamp = block.timestamp;
        _userFarmLockedAmount[account] += amount;
        _userLockedFarmRewards[account].push(
            LockedFarmReward({
                    _locked: amount,
                    _timestamp: currentTimestamp
                })
        );
    }

    function lockTradingReward(address account, uint256 amount) public override isTrading {
        require(amount > 0, "Invalid amount");
        if (_userLockedTradeRewards[account]._lastClaimTime == 0) {
            _userLockedTradeRewards[account]._lastClaimTime = _tradingStartTime;
        }
        if(_userLockedTradeRewards[account]._locked != 0) {
            claimTradingReward(account);
        }
        _userLockedTradeRewards[account]._locked += amount;
    }

    function claimFarmReward(uint256[] memory index) public override noReentrant {
        require(index.length <= _userLockedFarmRewards[msg.sender].length, "Invalid index.");
        for (uint256 i; i < index.length; i++) {
            uint256 bonus = getClaimableFarmReward(msg.sender, index[i]);
            _kaki.mint(msg.sender, bonus);
            _kaki.mint(_addTrading, (_userLockedFarmRewards[msg.sender][index[i]]._locked - bonus));
            _userLockedFarmRewards[msg.sender][index[i]] = _userLockedFarmRewards[msg.sender][_userLockedFarmRewards[msg.sender].length - 1];
            _userLockedFarmRewards[msg.sender].pop();
        }
    }

    function claimTradingReward(address account) public override noReentrant {
        require(_userLockedTradeRewards[account]._locked != 0, "You do not have bounus to claim.");
        uint256 bonus = getTradingUnlockedReward(account);
        _kaki.mint(account, bonus);
        _userLockedTradeRewards[account]._locked -= bonus;
        _userLockedTradeRewards[account]._lastClaimTime = block.timestamp;
    }

    //********************************  view **********************************/
    function getFarmAccInfo(address account) public override view returns (LockedFarmReward[] memory lockedReward, uint256[] memory claimableReward) {
        lockedReward = _userLockedFarmRewards[account];
        claimableReward = new uint256[](lockedReward.length);
        for(uint256 i = 0; i < _userLockedFarmRewards[account].length; i++) {
            claimableReward[i] = getClaimableFarmReward(msg.sender, i);
        }
    }
    
    function getClaimableFarmReward(address account, uint256 index) public override view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 unlockedAmount;
        LockedFarmReward[] memory user = _userLockedFarmRewards[account];
        if(index < user.length) {
            if(currentTime - user[index]._timestamp < _farmPeriod){
                uint256 claimableAmount = user[index]._locked * _farmRate / THOUSAND;
                unlockedAmount = claimableAmount + (user[index]._locked - claimableAmount) * (currentTime - user[index]._timestamp) / _farmPeriod;
            }
            else unlockedAmount = user[index]._locked;
        }
        return unlockedAmount;
    }

    function getTradingLockedReward(address account) public override view returns (uint256) {
        return _userLockedTradeRewards[account]._locked;
    }

    function getTradingUnlockedReward(address account) public override view returns (uint256 bonus) {
        uint256 currentTime = block.timestamp;
        if (currentTime - _userLockedTradeRewards[account]._lastClaimTime < _tradingPeriod) {
            bonus = _userLockedTradeRewards[account]._locked 
                            * (currentTime - _userLockedTradeRewards[account]._lastClaimTime) 
                            / (_tradingPeriod + _tradingStartTime - _userLockedTradeRewards[account]._lastClaimTime);
        } else {
            bonus = _userLockedTradeRewards[account]._locked;
        }
    }

    //**************************** admin function ****************************/
    function setTradingAdd(address newTradingAdd) public onlyOwner {
        require(newTradingAdd != address(0), "Invalid address.");
        _addTrading = newTradingAdd;
    }

    function setFarmAdd(address newFarmAdd) public onlyOwner {
        require(newFarmAdd != address(0), "Invalid address.");
        _addFarm = newFarmAdd;
    }

    function version() public pure returns (uint256) {
        return 2;
    }

}
