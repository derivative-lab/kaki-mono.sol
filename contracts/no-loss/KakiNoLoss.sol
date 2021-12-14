// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

import "./IAggregatorInterface.sol";
import "./IKakiNoLoss.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/WithAdminRole.sol";

contract KakiNoLoss is WithAdminRole, IKakiNoLoss {
    uint256 internal constant _BASE = 1000;
    uint256 internal constant _KTOKENDECIMALS = 10**18;

    IAggregatorInterface _aggregator;
    IERC20 internal _kakiToken;
    IERC20 internal _bnbToken;
    IERC20 internal _busdToken;
    IERC20 internal _kakiBNBToken;
    IERC20 internal _kakiBUSDToken;
    IERC20[] internal _tokenAssemble;
    uint256[] _tokenFactor;

    uint256 _weekTime;
    uint256 _dayTime;
    uint256 _roundTime;
    uint256 _tradingTime;
    uint256 _captionKC;
    uint256 _captionKAKI;
    uint256 public _captainRateLimit;
    uint256 public _kakiFoundationRate;
    address public _kakiFoundationAddress;

    uint256 public _chapter;
    uint256 public _lastRound;
    mapping(uint256 => uint256) public _chapterStartTime;
    mapping(uint256 => mapping(uint256 => uint256)) public _roundStartTime;
    mapping(uint256 => bool) public _isChapterEnd;
    mapping(uint256 => uint256) public _interest;

    uint256 public _nextFactionId;
    mapping(uint256 => Faction) public _factionStatus;
    mapping(address => Account) public _accountFactionInfo;
    mapping(address => mapping(uint256 => AccountFaction)) public _accountFactionStatus;

    mapping(uint256 => mapping(uint256 => Pool)) public _poolState;
    mapping(uint256 => uint256) public _winnerKC;
    struct Faction {
        address _captain;
        uint256 _captainBonus;
        uint256 _createTime;
        uint256 _lastCheckChapter;
        uint256[] _stakeAmount;
        mapping(uint256 => uint256) _lastFireRound;
        mapping(uint256 => uint256) _chapterKC;
        mapping(uint256 => uint256) _totalChapterKC;
        mapping(uint256 => uint256) _factionWinnerKC;
        mapping(uint256 => mapping(uint256 => FirePool)) _fire;
    }

    struct Account {
        uint256[] _factionArr;
        uint256 _bonusChapter;
    }

    struct AccountFaction {
        uint256 _lastCheckChapter;
        uint256 _lastCheckKC;
        uint256[] _stakeAmount;
        mapping(uint256 => uint256) _accountKC;
        uint256[] _accountKCIndex;
    }

    struct FirePool {
        uint256 _call;
        uint256 _put;
    }

    struct Pool {
        uint256 _call;
        uint256 _put;
        uint256 _answer;
    }

    function initialize(
        IERC20 kakiToken_,
        IERC20 bnbToken_,
        IERC20 busdToken_,
        IERC20 kakiBNBToken_,
        IERC20 kakiBUSDToken_,
        IAggregatorInterface aggregator_
    ) public initializer {
        __WithAdminRole_init();

        _weekTime = 1 weeks; // oneweek = 40320 15min = 60 1day1h = 6000 30min = 120 15s/block 1week = 604800 30min = 1800
        _dayTime = 1 days; // oneday = 5760 10min = 40 25min = 100 15s/block 1day = 86400 25min = 1500
        _roundTime = 5 minutes; // 2min = 8 5min = 20 15s/Block 5min = 300
        _tradingTime = 3 minutes; // 1.5min = 6 3min = 12 15s/Block 3min = 180
        _captionKAKI = 2020 ether;
        _captionKC = 100;

        _aggregator = aggregator_;
        _kakiToken = kakiToken_;
        _bnbToken = bnbToken_;
        _busdToken = busdToken_;
        _kakiBNBToken = kakiBNBToken_;
        _kakiBUSDToken = kakiBUSDToken_;
        _tokenAssemble = [_bnbToken, _busdToken, _kakiBNBToken, _kakiBUSDToken];
        _tokenFactor = [1, 2, 3, 4];

        _nextFactionId = 1;
        _chapterStartTime[0] = getTimestamp();

        _captainRateLimit = 80; // 8%
        _kakiFoundationRate = 50; // 5%
        _kakiFoundationAddress = 0x8a5871a06e847C0F696875AAdC25515063Bc0179;
    }

    function createFaction(uint256 nftId) public {
        uint256 time = getTimestamp();
        require(_chapterStartTime[_chapter] <= time, "please wait new _chapter!");

        _kakiToken.transferFrom(msg.sender, address(this), _captionKAKI);

        uint256 captionKc = calKc(_captionKC);
        _factionStatus[_nextFactionId]._captain = msg.sender;
        _factionStatus[_nextFactionId]._lastCheckChapter = _chapter;
        _factionStatus[_nextFactionId]._chapterKC[_chapter] = captionKc;
        _factionStatus[_nextFactionId]._createTime = time;

        _accountFactionStatus[msg.sender][_nextFactionId]._lastCheckChapter = _chapter;
        _accountFactionStatus[msg.sender][_nextFactionId]._accountKC[_chapter] = captionKc;
        _accountFactionStatus[msg.sender][_nextFactionId]._accountKCIndex.push(_chapter);
        if (_accountFactionInfo[msg.sender]._bonusChapter == 0)
            _accountFactionInfo[msg.sender]._bonusChapter = _chapter;
        _accountFactionInfo[msg.sender]._factionArr.push(_nextFactionId);
        emit CreateFaction(msg.sender, _nextFactionId, time);
        _nextFactionId++;
    }

    function joinFaction(
        uint256 factionId,
        uint256 tokenIndex,
        uint256 amount
    ) public {
        uint256 time = getTimestamp();
        require(factionId != 0, "Cannot join faction 0.");
        require(_chapterStartTime[_chapter] > time, "please wait new _chapter!");
        require(factionId < _nextFactionId, "Cannot join uncreated factions.");
        require(
            _accountFactionInfo[msg.sender]._factionArr.length == 0,
            "Before join a faction, please leave other factions."
        );
        require(amount > 0, "Amount must be greater than 0.");

        _tokenAssemble[tokenIndex].transferFrom(msg.sender, address(this), amount);

        updateFactioinAndAccount(factionId, tokenIndex, amount);

        _accountFactionInfo[msg.sender]._factionArr.push(_nextFactionId);
        if (_accountFactionInfo[msg.sender]._bonusChapter == 0)
            _accountFactionInfo[msg.sender]._bonusChapter = _chapter;
        emit JoinFaction(msg.sender, factionId, tokenIndex, amount, time);
    }

    function initFactionChapterKC(uint256 factionId) internal {
        if (_factionStatus[factionId]._lastCheckChapter != _chapter) {
            updateFactionWinnerAmount(factionId, _factionStatus[factionId]._lastCheckChapter);
            _factionStatus[factionId]._chapterKC[_chapter] =
                _captionKC +
                calFactionAllKcInWholeCycle(_factionStatus[factionId]._stakeAmount);

            _factionStatus[factionId]._lastCheckChapter = _chapter;
        }
    }

    function initAccountChapterKC(uint256 factionId) internal {
        if (_accountFactionStatus[msg.sender][factionId]._lastCheckChapter != _chapter) {
            uint256[] memory stakeAmount = _accountFactionStatus[msg.sender][factionId]._stakeAmount;
            uint256 accountKC = calFactionAllKcInWholeCycle(stakeAmount);
            if (_factionStatus[factionId]._captain == msg.sender) {
                accountKC = accountKC + _captionKC;
            }
            _accountFactionStatus[msg.sender][factionId]._lastCheckKC = accountKC;
            _accountFactionStatus[msg.sender][factionId]._accountKC[_chapter] = accountKC;
            _accountFactionStatus[msg.sender][factionId]._lastCheckChapter = _chapter;
        }
    }

    function updateFactioinAndAccount(
        uint256 factionId,
        uint256 id,
        uint256 amount
    ) internal {
        initFactionChapterKC(factionId);
        initAccountChapterKC(factionId);

        uint256 addKc = calKc(amount * _tokenFactor[id]);
        _factionStatus[factionId]._chapterKC[_chapter] += addKc;
        _factionStatus[factionId]._stakeAmount[id] += amount;

        _accountFactionStatus[msg.sender][factionId]._lastCheckKC += addKc;
        _accountFactionStatus[msg.sender][factionId]._accountKC[_chapter] += addKc;
        _accountFactionStatus[msg.sender][factionId]._accountKCIndex.push(_chapter);
        _accountFactionStatus[msg.sender][factionId]._stakeAmount[id] += amount;
    }

    function addStake(
        uint256 factionId,
        uint256 id,
        uint256 amount
    ) public {
        require(_accountFactionStatus[msg.sender][factionId]._lastCheckChapter > 0, "join a faction first");
        _tokenAssemble[id].transferFrom(msg.sender, address(this), amount);

        updateFactioinAndAccount(factionId, id, amount);
        emit AddStake(msg.sender, factionId, id, amount);
    }

    function leaveFaction(uint256 factionId) public {
        require(_accountFactionStatus[msg.sender][factionId]._lastCheckChapter > 0, "join a faction first");

        for (uint256 id; id < _tokenAssemble.length; id++) {
            uint256 stakeA = _accountFactionStatus[msg.sender][factionId]._stakeAmount[id];
            if (stakeA > 0) {
                _factionStatus[factionId]._stakeAmount[id] -= stakeA;
                _tokenAssemble[id].transfer(msg.sender, stakeA);
            }
        }
        if (_accountFactionStatus[msg.sender][factionId]._lastCheckChapter != _chapter) {
            _factionStatus[factionId]._chapterKC[_chapter] =
                _captionKC +
                calFactionAllKcInWholeCycle(_factionStatus[factionId]._stakeAmount);
        } else {
            _factionStatus[factionId]._chapterKC[_chapter] -= _accountFactionStatus[msg.sender][factionId]._lastCheckKC;
        }
        _factionStatus[factionId]._lastCheckChapter = _chapter;
        delete _accountFactionStatus[msg.sender][factionId];

        delAccountFaction(factionId);
        if (_factionStatus[factionId]._captain == msg.sender) _factionStatus[factionId]._captain = address(0);

        uint256 bonus = getBonus();
        if (bonus > 0) _kakiToken.transfer(msg.sender, bonus);

        emit LeaveFaction(msg.sender, factionId, bonus);
    }

    function delAccountFaction(uint256 factionId) internal {
        uint256 len = _accountFactionInfo[msg.sender]._factionArr.length;
        for (uint256 i; i < len; i++) {
            if (_accountFactionInfo[msg.sender]._factionArr[i] == factionId) {
                _accountFactionInfo[msg.sender]._factionArr[i] = _accountFactionInfo[msg.sender]._factionArr[len - 1];
                delete _accountFactionInfo[msg.sender]._factionArr[len - 1];
            }
        }
    }

    function getChapterKC(uint256 factionId) public view returns (uint256) {
        if (_factionStatus[factionId]._lastCheckChapter != _chapter) {
            return calKc(_captionKC) + calFactionAllKc(_factionStatus[factionId]._stakeAmount);
        }
        return _factionStatus[factionId]._chapterKC[_chapter];
    }

    function fire(
        uint256 factionId,
        uint256 amount,
        bool binary
    ) public {
        uint256 _time = getTimestamp();
        Faction storage fa = _factionStatus[factionId];
        bool isRoundFirstFire = _factionStatus[factionId]._fire[_chapter][_lastRound]._call == 0 &&
            _factionStatus[factionId]._fire[_chapter][_lastRound]._put == 0;

        require(amount > 0, "The amount cannot be 0.");
        require(_chapterStartTime[_chapter] + _dayTime >= _time, "The trading day has ended.");
        require(fa._captain == msg.sender, "The function caller must be the captain.");
        if (fa._lastCheckChapter != _chapter) {
            initFactionChapterKC(factionId);
        } else {
            if (isRoundFirstFire) updateFactionWinnerAmount(factionId, _chapter);
        }
        require(
            fa._chapterKC[_chapter - 1] >= amount,
            "The number of KC used cannot be greater than the number of remaining KC."
        );

        if (_factionStatus[factionId]._lastFireRound[_chapter] == 0)
            _factionStatus[factionId]._totalChapterKC[_chapter] = fa._chapterKC[_chapter];

        if (binary) {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._call += amount;
            _poolState[_chapter][_lastRound]._call += amount;
        } else {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._put += amount;
            _poolState[_chapter][_lastRound]._put += amount;
        }

        _factionStatus[factionId]._chapterKC[_chapter - 1] = fa._chapterKC[_chapter - 1] - amount;

        _factionStatus[factionId]._lastFireRound[_chapter] = _lastRound;
        emit Fire(msg.sender, _chapter, _lastRound, factionId, amount, binary, _time);
    }

    function addLoot() public {
        uint256 _time = getTimestamp();
        require(_chapterStartTime[_chapter] + _weekTime <= _time, "The _chapter is not over.");

        _lastRound = 1;
        _chapter++;
        _chapterStartTime[_chapter] = _time;
        _roundStartTime[_chapter][0] = _time;
    }

    function battleDamage() public {
        uint256 time = getTimestamp();
        require(_chapter != 0, "invalid operate.");
        require(!_isChapterEnd[_chapter], "The trading day is over.");
        require(
            _roundStartTime[_chapter][_lastRound] + _roundTime <= uint256(time),
            "This round of trading is not over."
        );

        _poolState[_chapter][_lastRound + 1]._answer = _aggregator.latestAnswer();
        uint256 winner;
        if (_poolState[_chapter][_lastRound]._answer < _poolState[_chapter][_lastRound + 1]._answer)
            winner = _poolState[_chapter][_lastRound - 1]._call;
        else winner = _poolState[_chapter][_lastRound - 1]._put;

        _winnerKC[_chapter] = (_winnerKC[_chapter]) + winner;

        if (
            (_chapterStartTime[_chapter]) + _dayTime <= uint256(time) &&
            _poolState[_chapter][_lastRound]._call == 0 &&
            _poolState[_chapter][_lastRound]._put == 0
        ) {
            _isChapterEnd[_chapter] = true;
            if (_winnerKC[_chapter] == 0) {
                uint256 currentInterest = _interest[_chapter];
                _interest[_chapter + 1] = currentInterest;
            }
        }

        _lastRound++;
        _roundStartTime[_chapter][_lastRound] = time;
    }

    function updateFactionWinnerAmount(uint256 factionId, uint256 factionChapter) internal {
        uint256 winner;
        if (
            factionChapter != _chapter ||
            (factionChapter == _chapter && _factionStatus[factionId]._lastFireRound[factionChapter] < _lastRound - 1)
        ) {
            uint256 lastFireRound = _factionStatus[factionId]._lastFireRound[factionChapter];
            if (
                _poolState[factionChapter][lastFireRound]._answer <
                _poolState[factionChapter][lastFireRound + 1]._answer
            ) winner = winner + _factionStatus[factionId]._fire[factionChapter][lastFireRound]._call;
            if (
                _poolState[factionChapter][lastFireRound]._answer >
                _poolState[factionChapter][lastFireRound + 1]._answer
            ) winner = winner + _factionStatus[factionId]._fire[factionChapter][lastFireRound]._put;
            if (factionChapter != _chapter && lastFireRound > 0) {
                if (
                    _poolState[factionChapter][lastFireRound - 1]._answer <
                    _poolState[factionChapter][lastFireRound]._answer
                ) winner = winner + _factionStatus[factionId]._fire[factionChapter][lastFireRound - 1]._call;
                if (
                    _poolState[factionChapter][lastFireRound - 1]._answer >
                    _poolState[factionChapter][lastFireRound]._answer
                ) winner = winner + _factionStatus[factionId]._fire[factionChapter][lastFireRound - 1]._put;
            }
            _factionStatus[factionId]._factionWinnerKC[factionChapter] += winner;
        }
    }

    function getAccountKC(uint256 factionId, uint256 chapter) internal returns (uint256) {
        uint256 len = _accountFactionStatus[msg.sender][_nextFactionId]._accountKCIndex.length;
        for (uint256 i = len - 1; i >= 0; i--) {
            uint256 c = _accountFactionStatus[msg.sender][_nextFactionId]._accountKCIndex[i];
            if (c <= chapter) return _accountFactionStatus[msg.sender][_nextFactionId]._accountKC[c];
        }
        return 0;
    }

    function claimBonus() public returns (uint256) {
        uint256 _time = getTimestamp();
        uint256 bonus = getBonus();
        if (bonus != 0) {
            _kakiToken.transfer(msg.sender, bonus);
            emit ClaimBonus(msg.sender, bonus);
        }
    }

    function getBonus() public returns (uint256) {
        uint256 bonus;

        for (uint256 ichapter = _accountFactionInfo[msg.sender]._bonusChapter; ichapter < _chapter; ichapter++) {
            for (uint256 fi; fi < _accountFactionInfo[msg.sender]._factionArr.length; fi++) {
                uint256 factionId = _accountFactionInfo[msg.sender]._factionArr[fi];
                initFactionChapterKC(factionId);
                Faction storage faction = _factionStatus[factionId];
                if (_winnerKC[ichapter] > 0 && faction._factionWinnerKC[ichapter] > 0) {
                    uint256 accountKc = getAccountKC(factionId, ichapter);
                    bonus +=
                        (_interest[ichapter] * accountKc * faction._factionWinnerKC[ichapter]) /
                        faction._totalChapterKC[ichapter] /
                        _winnerKC[ichapter];
                    if (faction._captain == msg.sender && faction._captainBonus != 0) {
                        bonus = bonus + faction._captainBonus;
                        faction._captainBonus = 0;
                    }
                }
            }
        }
        _accountFactionInfo[msg.sender]._bonusChapter = _chapter;
        return bonus;
    }

    function calKc(uint256 v) internal view returns (uint256) {
        uint256 time = getTimestamp();
        uint256 deltaTime = _weekTime - (time - _chapterStartTime[_chapter]);
        uint256 kc = (v * deltaTime) / _weekTime;
        return kc;
    }

    function calFactionAllKcInWholeCycle(uint256[] memory stakeAmount) internal view returns (uint256) {
        uint256 kc;
        uint256 len = stakeAmount.length;
        for (uint256 i; i < len; i++) {
            kc += stakeAmount[i] * _tokenFactor[i];
        }
        return kc;
    }

    function calFactionAllKc(uint256[] memory stakeAmount) internal view returns (uint256) {
        uint256 kc;
        uint256 len =  stakeAmount.length;
        for (uint256 i; i <len; i++) {
            kc += calKc(stakeAmount[i] * _tokenFactor[i]);
        }
        return kc;
    }

    /*
     * Get current time
     * @return Current time
     */
    function getTimestamp() public view virtual returns (uint256) {
        return block.timestamp;
    }
}
