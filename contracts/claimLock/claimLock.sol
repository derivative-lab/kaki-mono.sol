pragma solidity ^0.8.0;
import "./interface/IClaimLock.sol";
import "./interface/IKaki.sol";
import "../base/WithRandom.sol";
import "../base/WithAdminRole.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimLock is IClaimLock, WithAdminRole {
    IKaki  _kaki;
    uint256 constant THOUSAND = 10 ** 3;
    uint256 public _startTime;
    uint256 public _tradingStartTime;
    uint256 public _farmPeriod;
    uint256 public _tradingPeriod;
    uint256 public _farmRate;
    uint256 public _tradingRate;
    address public _addFarm;
    address public _addTrading;
    address public _addPool;
    
    mapping(address => LockedFarmReward[]) public _userLockedFarmRewards;
    mapping(address => LockedTradingReward) public _userLockedTradeRewards;
    mapping(address => uint256) public _userFarmUnlockedAmount;
    mapping(address => uint256) public _userFarmLockedAmount;

    modifier isFarm() {
        require(msg.sender == _addFarm, "Invalid address.");
        _;
    }

    modifier isTrading() {
        require(msg.sender == _addTrading, "Invalid address.");
        _;
    }

    function initialize(address farmAdd, address tradingAdd, IKaki kTokenAdd, address poolAdd) public initializer {
        __WithAdminRole_init();
        _farmPeriod = 7776000;
        _tradingPeriod = 15552000;
        //trading start time
        //_tradingStartTime = xxxxxxx
        _addFarm = farmAdd;
        _addTrading = tradingAdd;
        _addPool = poolAdd;
        _kaki = kTokenAdd;
        _farmRate = 500;
        _tradingRate = 200;
    }

    function lockFarmReward(address account, uint256 amount) public override isFarm {
        uint256 currentTimestamp = block.timestamp;
        uint256 claimableAmount = amount * _farmRate / THOUSAND;
        _userFarmUnlockedAmount[account] += amount - claimableAmount;
        _userFarmLockedAmount[account] += claimableAmount;
        _userLockedFarmRewards[account].push(
            LockedFarmReward({
                    _locked: claimableAmount,
                    _timestamp: currentTimestamp,
                    _claim: true
                })
        );
    }

    function lockTradingReward(address account, uint256 amount) public override isTrading {
        require(amount > 0, "Invalid amount");
        if(_userLockedTradeRewards[account]._lastClaimTime !=0) {
            claimTradingReward(msg.sender);
        }
        _userLockedTradeRewards[account]._locked += amount;
    }

    function claimFarmRewardAll() public override {
        uint256 bonus = getClaimableFarmReward(msg.sender);
        _kaki.mint(msg.sender, bonus);
        _kaki.mint(_addTrading, (_userFarmLockedAmount[msg.sender] - bonus));
        _userFarmLockedAmount[msg.sender] = 0;
        _userFarmUnlockedAmount[msg.sender] = 0;
        delete _userLockedFarmRewards[msg.sender];
    }

    function claimTradingReward(address account) public override {
        require(_userLockedTradeRewards[account]._lastClaimTime != 0, "You do not have bounus to claim.");
        uint256 bonus;
        uint256 currentTime = block.timestamp;
        if (currentTime - _userLockedTradeRewards[account]._lastClaimTime < _tradingPeriod) {
            bonus = _userLockedTradeRewards[account]._locked 
                            * (currentTime - _userLockedTradeRewards[account]._lastClaimTime) 
                            / _tradingPeriod;
        } else {
            bonus = _userLockedTradeRewards[account]._locked;
        }
        _kaki.mint(account, bonus);
        _userLockedTradeRewards[account]._locked -= bonus;
        _userLockedTradeRewards[account]._lastClaimTime = currentTime;
    }

    //********************************  view **********************************/
    function getClaimableFarmReward(address account) public override view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 unlockedAmount = _userFarmUnlockedAmount[account];
        LockedFarmReward[] memory user = _userLockedFarmRewards[account];
        if(user.length != 0) {
            for(uint256 i; i < user.length; i++) {
                if(currentTime - user[i]._timestamp < _farmPeriod){
                    if(user[i]._claim) {
                        unlockedAmount += user[i]._locked * (currentTime - user[i]._timestamp) / _farmPeriod;
                    }
                }
            }
        }
        return unlockedAmount;
    }

    function getTradingUnlockReward(address account) public override view returns (uint256) {
        return _userLockedTradeRewards[account]._locked;
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

    function setPoolAdd(address newPoolAdd) public onlyOwner {
        require(newPoolAdd != address(0), "Invalid address.");
        _addPool = newPoolAdd;
    }
}