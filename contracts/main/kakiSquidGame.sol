// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IKakiSquidGame.sol";
import "hardhat/console.sol";
import "./IAggregatorInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract KakiSquidGame is IKakiSquidGame, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;

    IERC20 internal _token;
    IAggregatorInterface _aggregator;
    uint256 _roundTime;
    uint256 _roundSum;
    uint256 _tradingTime;
    uint256 _gameInterval;
    uint256 _ticketPrice;
    uint256 _initChipNum;
    uint256 constant BASE = 10**18;
    uint256 constant THOUSAND = 10**3;
    uint256 public kakiFoundationRate;
    address public kakiFoundationAddress;

    uint256 public _chapter;
    uint256 public _lastRound;
    uint256 public _nextGameTime;

    address[] public _lastRoundUsers;
    mapping(uint256 => bool) public isChapterStart;
    mapping(uint256 => mapping(uint256 => uint256)) public _lastRoundStartTime;
    mapping(uint256 => mapping(address => uint256)) public _users;
    mapping(address => uint256) public _bonus;

    mapping(uint256 => uint256) public _totalBonus;
    mapping(uint256 => mapping(uint256 => uint256)) public _finalCall;
    mapping(uint256 => mapping(uint256 => uint256)) public _finalPut;
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public _placeCallStatus;
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public _placePutStatus;
    mapping(uint256 => mapping(uint256 => uint256)) public _price;
 

    modifier onlyNoneContract() {
        require(msg.sender == tx.origin, "only non contract call");
        _;
    }

    /*
     * Contract constructor
     */
    function initialize(address token_, address aggregator_) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        _aggregator = IAggregatorInterface(aggregator_);
        _token = IERC20(token_);

        _nextGameTime = 1637744431; //2021-11-24 17:00:07

        _roundSum = 5; //5round
        _gameInterval = 2100; //8hour = 28800 35min =2100
        _roundTime = 300; // 2min = 8 5min = 20 15s/Block 5min = 300
        _tradingTime = 180; // 1.5min = 6 3min = 12 15s/Block 3min = 180
        _ticketPrice = 100 * BASE;
        _initChipNum = 16;

        kakiFoundationRate = 50; // 5%
        kakiFoundationAddress = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d;
    }

    /*
     * User costs BUSD to join game  
     */
    function buyTicket() public override onlyNoneContract {
        require(_users[_chapter][msg.sender] != _initChipNum, "Had bought ticket.");
        uint256 time = getTimestamp();
        require(time < _nextGameTime, "The game is in the play status.");
        _users[_chapter][msg.sender] = _initChipNum;
        _totalBonus[_chapter] = _totalBonus[_chapter].add(_ticketPrice);
        _token.transferFrom(msg.sender, address(this), _ticketPrice);
        emit BuyTicket(msg.sender, _ticketPrice);
    }

    /*
     * Admin adds additional bonuses to current chapter pool before the game starts
     * @param extraAmount Additional bonuses.
     */
    function addBonus(uint256 extraAmount) public {
        uint256 time = getTimestamp();
        require(extraAmount > 0, "Invalid amount.");
        require(time < _nextGameTime, "The game is in the play status.");
        _totalBonus[_chapter] = _totalBonus[_chapter].add(extraAmount);
        _token.transferFrom(msg.sender, address(this), extraAmount);
    }

    /*
     * User places order
     * @param amount The amount of chip placing call order.
     */
    function placeBet(uint256 amount) public override onlyNoneContract {
        require(roundStatus(), "The current round of trading ends.");
        uint256 roundChip = getRoundChip();
        require(roundChip != 0, "Invalid order place.");
        require(
            roundChip >= amount,
            "The number of chips used cannot be greater than the number of remaining chips."
        );
        require(_placeCallStatus[_chapter][_lastRound][msg.sender] == 0 && _placePutStatus[_chapter][_lastRound][msg.sender] == 0, "Had placed order in this round");
        if (_lastRound == _roundSum - 1) _lastRoundUsers.push(msg.sender);

        _placeCallStatus[_chapter][_lastRound][msg.sender] = amount;
        _finalCall[_chapter][_lastRound] = _finalCall[_chapter][_lastRound].add(amount);

        _placePutStatus[_chapter][_lastRound][msg.sender] = roundChip.sub(amount);
        _finalPut[_chapter][_lastRound] = _finalPut[_chapter][_lastRound].add(roundChip.sub(amount));

        emit PlaceBet(msg.sender, amount);
    }

    /*
     * Claim bonus
     */
    function claim() public override onlyNoneContract {
        uint256 b = getUserBonus();
        require(b > 0, "bonus must > 0.");
        _token.transfer(msg.sender, b);
        _bonus[msg.sender] = 0;
        emit Claim(msg.sender, b);
    }

    /*
     * Settlement after the end of the round or chapter
     */
    function settle() public {
        uint256 time = getTimestamp();
        uint256 chapterEndTime = _nextGameTime.add((_lastRound + 1).mul(_roundTime));
        require(chapterEndTime <= time, "This round of trading is not over.");
        _price[_chapter][++_lastRound] = _aggregator.latestAnswer();
        _lastRoundStartTime[_chapter][_lastRound] = time;

        if (_lastRound >= _roundSum) {
            uint256 bonus = _totalBonus[_chapter];
            uint256 foundationBonus = bonus.mul(kakiFoundationRate).div(THOUSAND);
            bonus = bonus.sub(foundationBonus);
            if (foundationBonus != 0) {
                _token.transfer(kakiFoundationAddress, foundationBonus);
            }
            _settlement(bonus);
            delete _lastRoundUsers;

            _chapter++;
            _nextGameTime = _nextGameTime.add(_gameInterval);
        }
        emit Settle(msg.sender, _lastRound, time, _price[_chapter][_lastRound - 1], _price[_chapter][_lastRound]);
    }

    /*
     * Stop buy ticket & start game
     */
    function addLoot() public {
        uint256 time = getTimestamp();
        require(_nextGameTime <= time, "The chapter is not start.");
        require(!isChapterStart[_chapter], "The chapter is already start.");

        _nextGameTime = time;

        isChapterStart[_chapter] = true;
        _lastRound = 0;
        _lastRoundStartTime[_chapter][_lastRound] = time;
        _price[_chapter][0] = _aggregator.latestAnswer();
        emit AddLoot(msg.sender, _nextGameTime, _totalBonus[_chapter]);
    }

    function _settlement(uint256 bonus) internal {
        uint256 totalWinnerChip;
        if (_price[_chapter][_lastRound - 1] < _price[_chapter][_lastRound]) {
            if(_finalCall[_chapter][_roundSum - 1] != 0) {
                for (uint256 i; i < _lastRoundUsers.length; i++) {
                    address sender = _lastRoundUsers[i];
                    _bonus[sender] = _bonus[sender].add(
                        bonus.mul(_placeCallStatus[_chapter][_lastRound - 1][sender]).div(
                            _finalCall[_chapter][_roundSum - 1]
                        )
                    );
                } 
            }
            totalWinnerChip = _finalCall[_chapter][_roundSum - 1];
        } else {
            if(_finalPut[_chapter][_roundSum - 1] != 0) {
                for (uint256 i; i < _lastRoundUsers.length; i++) {
                    address sender = _lastRoundUsers[i];
                    _bonus[sender] = _bonus[sender].add(
                        bonus.mul(_placePutStatus[_chapter][_lastRound - 1][sender]).div(_finalPut[_chapter][_roundSum - 1])
                    );
                }
            }
            totalWinnerChip = _finalPut[_chapter][_roundSum - 1];
        }

        if (totalWinnerChip == 0) _token.transfer(kakiFoundationAddress, bonus);
    }

    function getRoundChip() public view override returns (uint256) {
        if (_lastRound == 0) return _users[_chapter][msg.sender];
        if (_price[_chapter][_lastRound - 1] < _price[_chapter][_lastRound])
            return _placeCallStatus[_chapter][_lastRound - 1][msg.sender];
        else return _placePutStatus[_chapter][_lastRound - 1][msg.sender];
    }

    function getUserBonus() public view override returns (uint256) {
        return _bonus[msg.sender];
    }

    function roundStatus() public view override returns (bool) {
        uint256 time = getTimestamp();
        uint256 currentRoundTime = _lastRoundStartTime[_chapter][_lastRound];
        if ((currentRoundTime + _tradingTime) > time && time >= currentRoundTime) return true;
        else return false;
    }

    function getTotalCall(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _finalCall[chapter][round];
    }

    function getTotalPut(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _finalPut[chapter][round];
    }

    function getMyCall(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _placeCallStatus[chapter][round][msg.sender];
    }

    function getMyPut(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _placePutStatus[chapter][round][msg.sender];
    }

    function getCurrentChapterRound() public view override returns (uint256, uint256) {
        return (_chapter, _lastRound);
    }

    function getHistoryChapMsg(uint256 chapter) public view override returns (RoundView[] memory chap){
        chap = new RoundView[](_roundSum+1);
        for(uint i; i < _roundSum; i++) {
            chap[i].totalCall = getTotalCall(chapter, i);
            chap[i].totalPut = getTotalPut(chapter, i);
            chap[i].accCall = getMyCall(chapter, i);
            chap[i].accPut = getMyPut(chapter, i);
            chap[i].price = getRoundPrice(chapter, i);
            chap[i].roundId = i;
        }
        chap[_roundSum].price = getRoundPrice(chapter, _roundSum);
    }

    function getTotalBonus(uint256 chapter) public view override returns (uint256) {
        return _totalBonus[chapter];
    }

    function getRoundPrice(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _price[chapter][round];
    }

    function getTimestamp() public view override returns (uint256) {
        return block.timestamp;
    }

    function updateNextGameTime(uint256 gameTime) public onlyOwner {
        require(!isChapterStart[_chapter], "The chapter is already start.");
        _nextGameTime = gameTime;
    }

    /*
     * Update the receiving address of Kaki foundation
     * @param newKakiFoundationAddress New receiving address
     */
    function updateKakiFoundationAddress(address newKakiFoundationAddress) public onlyOwner {
        require(newKakiFoundationAddress != address(0), "The address cannot be 0.");
        kakiFoundationAddress = newKakiFoundationAddress;
    }

    /*
     * Update the address of Oracle
     * @param oracleAddress New oracle Address
     */
    function updateKakiOracleAddress(address oracleAddress) public onlyOwner {
        require(oracleAddress != address(0), "The address cannot be 0.");
        _aggregator = IAggregatorInterface(oracleAddress);
    }    
}
