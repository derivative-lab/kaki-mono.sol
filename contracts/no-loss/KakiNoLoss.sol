// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;
import "./IAggregatorInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IKakiNoLoss.sol";
import "../interfaces/IKakiCaptain.sol";
import "hardhat/console.sol";

contract KakiNoLoss is WithAdminRole, IKakiNoLoss {
    uint256 internal constant _BASE = 1000;

    IAggregatorInterface _aggregator;
    IKakiCaptain internal _captainNFT;
    IERC20 internal _kakiToken;
    IERC20 internal _bnbToken;
    IERC20 internal _busdToken;
    IERC20 internal _kakiBNBToken;
    IERC20 internal _kakiBUSDToken;
    IERC20[] internal _tokenAssemble;
    uint256[] _tokenFactor;

    uint256 _depositTokenSort;
    uint256 _weekTime;
    uint256 _dayTime;
    uint256 _roundTime;
    uint256 _tradingTime;
    uint256 _captionKC;
    uint256 _captionKAKI;

    uint256 public _nextFactionId;
    uint256 public _captainRateLimit;
    uint256 public _kakiFoundationRate;
    uint256 public _chapter;
    uint256 public _lastRound;
    address public _kakiFoundationAddress;

    mapping(uint256 => Faction) public _factionStatus;
    mapping(uint256 => ChapterStru) public _chapterStatus;
    mapping(uint256 => mapping(uint256 => Pool)) public _poolState;

    mapping(address => Account) public _accountGlobalInfo;
    mapping(address => mapping(uint256 => AccountFaction)) public _accountFactionStatus;

    struct ChapterStru {
        bool _isEnd;
        uint256 _startTime;
        uint256 _interest;
        uint256 _nftFactionInterest;
        uint256 _winnerKC;
        uint256 _nftFactionWKC;
        mapping(uint256 => uint256) _roundStartTime;
    }

    struct Faction {
        address _captain;
        uint256 _kcAddRatio;
        uint256 _memberNum;
        uint256 _winFireCnt;
        uint256 _totalFireCnt;
        uint256 _totalBonus;
        uint256 _nftId;
        uint256 _enableWhiteList;
        uint256 _captainBonus;
        uint256 _createTime;
        uint256 _lastCheckChapter;
        uint256 _lastIndexChapter;
        uint256 _totalIndex;
        address[] _accountArr;
        mapping(uint256 => uint256) _index;
        mapping(address => uint256) _whiteList;
        mapping(uint256 => uint256) _chapterKC;
        mapping(uint256 => uint256) _totalChapterKC;
        mapping(uint256 => uint256) _factionWinnerKC;
        mapping(uint256 => uint256) _stakeAmount;
        mapping(uint256 => uint256[]) _lastFireRound;
        mapping(uint256 => mapping(uint256 => FirePool)) _fire;
    }

    struct Account {
        uint256[] _factionArr;
        uint256 _bonusChapter;
    }

    struct AccountFaction {
        uint256 _lastCheckChapter;
        uint256 _lastCheckKC;
        mapping(uint256 => uint256) _stakeAmount;
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
        uint256 _nftFactionCall;
        uint256 _nftFactionPut;
        uint256 _answer;
    }

    function initialize(
        IKakiCaptain captionNft,
        IERC20 kakiToken_,
        IERC20 bnbToken_,
        IERC20 busdToken_,
        IERC20 kakiBNBToken_,
        IERC20 kakiBUSDToken_,
        IAggregatorInterface aggregator_
    ) public initializer {
        __WithAdminRole_init();

        _weekTime = 7 days; //40 minutes;
        _dayTime = 1 days; //25 minutes;
        _roundTime = 5 minutes; // 2min = 8 5min = 20 15s/Block 5min = 300
        _tradingTime = 3 minutes; // 1.5min = 6 3min = 12 15s/Block 3min = 180
        _captionKAKI = 2020 ether;
        _captionKC = 100 ether;
        _depositTokenSort = 4;

        _captainNFT = captionNft;
        _aggregator = aggregator_;
        _kakiToken = kakiToken_;
        _bnbToken = bnbToken_;
        _busdToken = busdToken_;
        _kakiBNBToken = kakiBNBToken_;
        _kakiBUSDToken = kakiBUSDToken_;
        _tokenAssemble = [_bnbToken, _busdToken, _kakiBNBToken, _kakiBUSDToken];
        _tokenFactor = [1000, 2000, 3000, 4000];

        _nextFactionId = 1;
        _chapter = 1;
        _chapterStatus[_chapter]._startTime = getTimestamp();

        _captainRateLimit = 80; // 8%
        _kakiFoundationRate = 50; // 5%
        _kakiFoundationAddress = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d;
    }

    function createFaction(uint256 nftId) public override {
        uint256 time = getTimestamp();
        require(_chapterStatus[_chapter]._startTime + _weekTime > time, "please wait new _chapter!");

        if (nftId > 0) {
            require(_captainNFT.ownerOf(nftId) == msg.sender, "not owner");
            IKakiCaptain.CapStatus memory captionStatus = _captainNFT.getCapStatus(nftId);
            require(!captionStatus.noCreateTeam, "cann't create again!");

            IKakiCaptain.CapPara memory captaionInfo = _captainNFT.getCapInfo(nftId);
            _factionStatus[_nextFactionId]._kcAddRatio = captaionInfo.miningRate * _BASE;
            _factionStatus[_nextFactionId]._memberNum = captaionInfo.memberNum;
            _factionStatus[_nextFactionId]._nftId = nftId;
            _captainNFT.setCapCreate(nftId);
        } else {
            require(
                _accountGlobalInfo[msg.sender]._factionArr.length == 0,
                "Before create a normal faction, please leave other factions."
            );
            _factionStatus[_nextFactionId]._kcAddRatio = 1 * _BASE;
        }
        _kakiToken.transferFrom(msg.sender, address(this), _captionKAKI);

        uint256 captionKc = calKc(_factionStatus[_nextFactionId]._kcAddRatio, _captionKC);
        _factionStatus[_nextFactionId]._captain = msg.sender;
        _factionStatus[_nextFactionId]._lastCheckChapter = _chapter;
        _factionStatus[_nextFactionId]._lastIndexChapter = _chapter;
        _factionStatus[_nextFactionId]._chapterKC[_chapter] = captionKc;
        _factionStatus[_nextFactionId]._createTime = time;
        _factionStatus[_nextFactionId]._accountArr.push(msg.sender);

        updateBonus();
        initAccountChapterKcInner(_nextFactionId, _chapter, captionKc);
        _accountFactionStatus[msg.sender][_nextFactionId]._lastCheckChapter = _chapter;
        _accountGlobalInfo[msg.sender]._factionArr.push(_nextFactionId);
        emit CreateFaction(msg.sender, _nextFactionId, nftId, time);
        _nextFactionId++;
    }

    function setWhiteList(uint256 _enableWhiteList) public {}


    function joinFaction(
        uint256 factionId,
        uint256 tokenIndex,
        uint256 amount
    ) public override {
        uint256 time = getTimestamp();
        require(factionId != 0, "Cannot join faction 0.");
        require(_chapterStatus[_chapter]._startTime + _weekTime > time, "please wait new _chapter!");
        require(factionId < _nextFactionId, "Cannot join uncreated factions.");
        require(
            _accountGlobalInfo[msg.sender]._factionArr.length == 0,
            "Before join a faction, please leave other factions."
        );
        require(amount > 0, "Amount must be greater than 0.");

        if (_factionStatus[factionId]._nftId > 0) {
            require(
                _factionStatus[factionId]._accountArr.length < _factionStatus[_nextFactionId]._memberNum,
                "member limit"
            );
            if (_factionStatus[factionId]._enableWhiteList == 1)
                require(_factionStatus[factionId]._whiteList[msg.sender] > 1, "need in white list");
        }
        _tokenAssemble[tokenIndex].transferFrom(msg.sender, address(this), amount);
        updateBonus();
        updateFactioinAndAccount(factionId, tokenIndex, amount);

        _factionStatus[factionId]._accountArr.push(msg.sender);
        _accountGlobalInfo[msg.sender]._factionArr.push(factionId);
        emit JoinFaction(msg.sender, factionId, tokenIndex, amount, time);
    }

    function initFactionChapterKC(uint256 factionId) internal {
        uint256 lastCheckChapter = _factionStatus[factionId]._lastCheckChapter;
        if (lastCheckChapter != _chapter) {
            updateFactionWinnerAmount(factionId, lastCheckChapter);
            if (_factionStatus[factionId]._lastIndexChapter < _chapter) updateFactionIndex(factionId, lastCheckChapter);

            _factionStatus[factionId]._chapterKC[_chapter] = _captionKC + calAllKcInWholeCycle(factionId, _factionStatus[factionId]._stakeAmount);
            _factionStatus[factionId]._lastCheckChapter = _chapter;
        } else {
            if (_chapterStatus[_chapter]._isEnd && _factionStatus[factionId]._lastIndexChapter < _chapter)
                updateFactionIndex(factionId, _chapter);
        }
        console.log("initFactionChapterKC", factionId, _chapter, lastCheckChapter);
    }

    function updateFactionIndex(uint256 factionId, uint256 chapter) internal {
        Faction storage fa = _factionStatus[factionId];
        uint256 factionWinnerKC = fa._factionWinnerKC[chapter];
        uint256 totalChapterKC = fa._totalChapterKC[chapter - 1];
        if (_chapterStatus[chapter]._winnerKC > 0) {
            uint256 teamBonus = _chapterStatus[chapter]._interest * factionWinnerKC / _chapterStatus[chapter]._winnerKC;
            if (_factionStatus[factionId]._nftId > 0 && factionWinnerKC > 0)
                teamBonus += _chapterStatus[chapter]._nftFactionInterest * factionWinnerKC / _chapterStatus[chapter]._nftFactionWKC;

            uint256 kakiFoundationBonus = (teamBonus * _kakiFoundationRate) / _BASE;
            _factionStatus[factionId]._totalBonus += (teamBonus - kakiFoundationBonus);

            uint256 captainBonus = (teamBonus * _captainRateLimit) / _BASE;
            teamBonus = teamBonus - captainBonus - kakiFoundationBonus;
            if (captainBonus != 0) {
                if (fa._captain == address(0)) kakiFoundationBonus += captainBonus;
                else _factionStatus[factionId]._captainBonus += captainBonus;
            }
            if (kakiFoundationBonus != 0) {
                _kakiToken.transfer(_kakiFoundationAddress, kakiFoundationBonus);
            }
            console.log("updateFactionIndex", chapter, teamBonus, totalChapterKC);
            _factionStatus[factionId]._totalIndex += (teamBonus * _BASE) / totalChapterKC;
        }
        _factionStatus[factionId]._index[chapter] = _factionStatus[factionId]._totalIndex;
        _factionStatus[factionId]._lastIndexChapter = chapter;

        console.log(
            "updateFactionIndex",
            factionId,
            _factionStatus[factionId]._lastIndexChapter,
            _factionStatus[factionId]._totalIndex
        );
    }

    function initAccountChapterKcInner(
        uint256 factionId,
        uint256 chapter,
        uint256 kc
    ) internal {
        _accountFactionStatus[msg.sender][factionId]._accountKC[chapter] = kc;
        _accountFactionStatus[msg.sender][factionId]._accountKCIndex.push(chapter);
    }

    function initAccountChapterKC(uint256 factionId) internal {
        uint256 lastCheckChpater = _accountFactionStatus[msg.sender][factionId]._lastCheckChapter;
        if (lastCheckChpater != 0 && lastCheckChpater != _chapter) {
            uint256 accountKC = calAccountKCInWholeCycle(factionId);
            _accountFactionStatus[msg.sender][factionId]._lastCheckKC = accountKC;
            _accountFactionStatus[msg.sender][factionId]._accountKC[_chapter] = accountKC;
            if (_chapter > lastCheckChpater + 1) {
                initAccountChapterKcInner(factionId, lastCheckChpater + 1, accountKC);
            }
            console.log("initAccountChapterKC", lastCheckChpater, _chapter, accountKC);
        }
        _accountFactionStatus[msg.sender][factionId]._lastCheckChapter = _chapter;
    }

    function updateFactioinAndAccount(
        uint256 factionId,
        uint256 id,
        uint256 amount
    ) internal {
        initFactionChapterKC(factionId);
        initAccountChapterKC(factionId);

        uint256 addKc = calKc(_factionStatus[factionId]._kcAddRatio, (amount * _tokenFactor[id]) / _BASE);
        _factionStatus[factionId]._chapterKC[_chapter] += addKc;
        _factionStatus[factionId]._stakeAmount[id] += amount;
        _accountFactionStatus[msg.sender][factionId]._lastCheckKC += addKc;
        initAccountChapterKcInner(
            factionId,
            _chapter,
            _accountFactionStatus[msg.sender][factionId]._accountKC[_chapter] + addKc
        );

        _accountFactionStatus[msg.sender][factionId]._stakeAmount[id] += amount;
    }

    function addStake(
        uint256 factionId,
        uint256 id,
        uint256 amount
    ) public override {
        require(_accountFactionStatus[msg.sender][factionId]._lastCheckChapter > 0, "join a faction first");
        _tokenAssemble[id].transferFrom(msg.sender, address(this), amount);
        uint256 time = getTimestamp();
        updateFactioinAndAccount(factionId, id, amount);
        updateBonus();
        emit AddStake(msg.sender, factionId, id, amount, time);
    }

    function _getCaptionLeaveKAKIReturn(uint256 factionId) internal returns (uint256) {
        uint256 time = getTimestamp();
        uint256 deduct;
        if (time - _factionStatus[_nextFactionId]._createTime <= 24 * 60 * 60) deduct = (_captionKAKI * 2) / 100;
        else if (time - _factionStatus[_nextFactionId]._createTime <= 72 * 60 * 60) deduct = _captionKAKI / 100;
        else if (time - _factionStatus[_nextFactionId]._createTime <= 96 * 60 * 60) deduct = (_captionKAKI * 5) / 1000;
        if (_factionStatus[_nextFactionId]._nftId > 0) deduct = deduct / 2;
        return _captionKAKI - deduct;
    }

    function leaveFaction(uint256 factionId) public override {
        uint256 time = getTimestamp();
        require(_accountFactionStatus[msg.sender][factionId]._lastCheckChapter > 0, "join a faction first");

        for (uint256 id; id < _tokenAssemble.length; id++) {
            uint256 stakeA = _accountFactionStatus[msg.sender][factionId]._stakeAmount[id];
            if (stakeA > 0) {
                _factionStatus[factionId]._stakeAmount[id] -= stakeA;
                _tokenAssemble[id].transfer(msg.sender, stakeA);
            }
        }

        if (_factionStatus[factionId]._captain == msg.sender) {
            _kakiToken.transfer(msg.sender, _getCaptionLeaveKAKIReturn(factionId));
            if (_factionStatus[factionId]._nftId > 0) _captainNFT.setCapCreate(_factionStatus[factionId]._nftId);
        }

        if (_accountFactionStatus[msg.sender][factionId]._lastCheckChapter != _chapter) {
            _factionStatus[factionId]._chapterKC[_chapter] = _captionKC + calAllKcInWholeCycle(factionId, _factionStatus[factionId]._stakeAmount);
        } else {
            _factionStatus[factionId]._chapterKC[_chapter] -= _accountFactionStatus[msg.sender][factionId]._lastCheckKC;
        }
        _factionStatus[factionId]._lastCheckChapter = _chapter;
        delete _accountFactionStatus[msg.sender][factionId];

        delFactionAccount(factionId);
        delAccountFaction(factionId);
        if (_factionStatus[factionId]._captain == msg.sender) _factionStatus[factionId]._captain = address(0);

        uint256 bonus = updateBonus();
        emit LeaveFaction(msg.sender, factionId, bonus, time);
    }

    function delFactionAccount(uint256 factionId) internal {
        uint256 len = _factionStatus[factionId]._accountArr.length;
        for (uint256 i; i < len; i++) {
            if (_factionStatus[factionId]._accountArr[i] == msg.sender) {
                _factionStatus[factionId]._accountArr[i] = _factionStatus[factionId]._accountArr[len - 1];
                _factionStatus[factionId]._accountArr.pop();
                return;
            }
        }
    }

    function delAccountFaction(uint256 factionId) internal {
        uint256 len = _accountGlobalInfo[msg.sender]._factionArr.length;
        for (uint256 i; i < len; i++) {
            if (_accountGlobalInfo[msg.sender]._factionArr[i] == factionId) {
                _accountGlobalInfo[msg.sender]._factionArr[i] = _accountGlobalInfo[msg.sender]._factionArr[len - 1];
                _accountGlobalInfo[msg.sender]._factionArr.pop();
                return;
            }
        }
    }

    function getChapterKC(uint256 factionId) public view returns (uint256) {
        if (_factionStatus[factionId]._lastCheckChapter != _chapter) {
            if (_chapter > _factionStatus[factionId]._lastCheckChapter + 1)
                return calKc(_factionStatus[factionId]._kcAddRatio, _captionKC) + calFactionAllKc(factionId);
            else return _factionStatus[factionId]._chapterKC[_chapter - 1];
        }
        return _factionStatus[factionId]._chapterKC[_chapter - 1];
    }

    function isRoundFire(
        uint256 factionId,
        uint256 chapter,
        uint256 round
    ) public view returns (bool) {
        return
            _factionStatus[factionId]._fire[chapter][round]._call > 0 ||
            _factionStatus[factionId]._fire[chapter][round]._put > 0;
    }

    function fire(
        uint256 factionId,
        uint256 amount,
        bool binary
    ) public override {
        uint256 time = getTimestamp();
        uint256 lastCheckChpater = _factionStatus[factionId]._lastCheckChapter;
        require(amount > 0, "The amount cannot be 0.");
        require(_chapterStatus[_chapter]._startTime + _dayTime >= time, "The trading day has ended.");
        require(_factionStatus[factionId]._captain == msg.sender, "The function caller must be the captain.");
        if (_factionStatus[factionId]._lastCheckChapter != _chapter) {
            console.log("fire lastCheckChapter");
            initFactionChapterKC(factionId);
            if (_chapter > lastCheckChpater + 1)
                _factionStatus[factionId]._chapterKC[_chapter - 1] = _factionStatus[factionId]._chapterKC[_chapter];
        } else {
            bool hasRoundFire = isRoundFire(factionId, _chapter, _lastRound);
            if (!hasRoundFire) updateFactionWinnerAmount(factionId, _chapter);
        }
        console.log(
            "fire kc",
            _factionStatus[factionId]._chapterKC[_chapter - 1],
            _factionStatus[factionId]._chapterKC[_chapter - 1] - amount
        );
        require(
            _factionStatus[factionId]._chapterKC[_chapter - 1] >= amount,
            "The number of KC used cannot be greater than the number of remaining KC."
        );

        _factionStatus[factionId]._totalFireCnt++;
        if (binary) {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._call += amount;
            _poolState[_chapter][_lastRound]._call += amount;
            if (_factionStatus[factionId]._nftId > 0) _poolState[_chapter][_lastRound]._nftFactionCall += amount;
        } else {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._put += amount;
            _poolState[_chapter][_lastRound]._put += amount;
            if (_factionStatus[factionId]._nftId > 0) _poolState[_chapter][_lastRound]._nftFactionPut += amount;
        }

        uint256 len = _factionStatus[factionId]._lastFireRound[_chapter].length;
        if (len == 0)
            _factionStatus[factionId]._totalChapterKC[_chapter - 1] = _factionStatus[factionId]._chapterKC[_chapter - 1];
        if (len == 0 || _factionStatus[factionId]._lastFireRound[_chapter][len - 1] != _lastRound)
            _factionStatus[factionId]._lastFireRound[_chapter].push(_lastRound);
        _factionStatus[factionId]._chapterKC[_chapter - 1] -= amount;
        emit Fire(msg.sender, _chapter, _lastRound, factionId, amount, binary, time);
    }

    function addLoot() public {
        uint256 time = getTimestamp();
        require(_chapterStatus[_chapter]._startTime + _weekTime <= time, "The _chapter is not over.");

        _lastRound = 1;
        _chapter++;

        _chapterStatus[_chapter]._startTime = time;
        _chapterStatus[_chapter]._roundStartTime[_lastRound] = time;
        _poolState[_chapter][1]._answer = _aggregator.latestAnswer();
        emit AddLoot(_chapter, _chapterStatus[_chapter]._interest, _chapterStatus[_chapter]._nftFactionInterest, time);
    }

    function battleDamage() public {
        uint256 time = getTimestamp();
        require(_chapter != 0, "invalid operate.");
        require(!_chapterStatus[_chapter]._isEnd, "The trading day is over.");
        require(
            _chapterStatus[_chapter]._roundStartTime[_lastRound] + _roundTime <= uint256(time),
            "This round of trading is not over."
        );

        _poolState[_chapter][_lastRound + 1]._answer = _aggregator.latestAnswer();
        uint256 winner;
        uint256 nftFactionWinner;
        if (_poolState[_chapter][_lastRound]._answer < _poolState[_chapter][_lastRound + 1]._answer) {
            winner = _poolState[_chapter][_lastRound - 1]._call;
            nftFactionWinner = _poolState[_chapter][_lastRound - 1]._nftFactionCall;
        } else {
            winner = _poolState[_chapter][_lastRound - 1]._put;
            nftFactionWinner = _poolState[_chapter][_lastRound - 1]._nftFactionPut;
        }

        _chapterStatus[_chapter]._winnerKC += winner;
        _chapterStatus[_chapter]._nftFactionWKC += nftFactionWinner;
        console.log("battleDamage", _chapter, _lastRound, _chapterStatus[_chapter]._winnerKC);

        if (
            (_chapterStatus[_chapter]._startTime) + _dayTime <= uint256(time) &&
            _poolState[_chapter][_lastRound]._call == 0 &&
            _poolState[_chapter][_lastRound]._put == 0
        ) {
            _chapterStatus[_chapter]._isEnd = true;
            if (_chapterStatus[_chapter]._winnerKC == 0) {
                uint256 currentInterest = _chapterStatus[_chapter]._interest;
                _chapterStatus[_chapter + 1]._interest = currentInterest;
            }
        }

        emit BattleDamage(
            _chapter,
            _lastRound,
            _poolState[_chapter][_lastRound]._answer,
            _poolState[_chapter][_lastRound + 1]._answer,
            time
        );

        _lastRound++;
        _chapterStatus[_chapter]._roundStartTime[_lastRound] = time;
    }

    function getRoundWinnerKc(
        uint256 factionId,
        uint256 chapter,
        uint256 round
    ) internal view returns (uint256) {
        if (_poolState[chapter][round + 1]._answer < _poolState[chapter][round + 2]._answer) {
            return _factionStatus[factionId]._fire[chapter][round]._call;
        }
        if (_poolState[chapter][round + 1]._answer > _poolState[chapter][round + 2]._answer)
            return _factionStatus[factionId]._fire[chapter][round]._put;
        return 0;
    }

    function checkRoundWinnerKc(
        uint256 factionId,
        uint256 chapter,
        uint256 round
    ) internal returns (uint256) {
        uint256 wkc = getRoundWinnerKc(factionId, chapter, round);
        if (wkc > 0) _factionStatus[factionId]._winFireCnt++;
        return wkc;
    }

    function updateFactionWinnerAmount(uint256 factionId, uint256 factionChapter) internal {
        uint256 fireLen = _factionStatus[factionId]._lastFireRound[factionChapter].length;
        uint256 winner;
        if (fireLen > 0) {
            uint256 lastRound = _factionStatus[factionId]._lastFireRound[factionChapter][fireLen - 1];
            console.log("updateFactionWinnerAmount", factionChapter, lastRound, _lastRound);
            if (factionChapter != _chapter || lastRound != _lastRound - 1) {
                winner += checkRoundWinnerKc(factionId, factionChapter, lastRound);
                console.log("updateFactionWinnerAmount2", winner);
                if (
                    fireLen > 1 &&
                    _factionStatus[factionId]._lastFireRound[factionChapter][fireLen - 2] == lastRound - 1
                ) winner += checkRoundWinnerKc(factionId, factionChapter, lastRound - 1);
            } else {
                if (
                    fireLen > 1 &&
                    _factionStatus[factionId]._lastFireRound[factionChapter][fireLen - 2] == lastRound - 1
                ) winner += checkRoundWinnerKc(factionId, factionChapter, lastRound - 1);
            }
        }
        _factionStatus[factionId]._factionWinnerKC[factionChapter] += winner;
        console.log(
            "updateFactionWinnerAmount",
            factionId,
            _lastRound,
            _factionStatus[factionId]._factionWinnerKC[factionChapter]
        );
    }

    function getAccountKC(
        address user,
        uint256 factionId,
        uint256 chapter
    ) public view  returns (uint256) {
        uint256 len = _accountFactionStatus[user][factionId]._accountKCIndex.length;
        console.log('chapter',chapter);
        console.log('accountkc',len);
        if(len==0 || chapter==0)
            return 0;
        if (chapter > _accountFactionStatus[user][factionId]._accountKCIndex[len - 1]) {
            return calAccountKCInWholeCycle(factionId);
        }
        for (uint256 i = len; i > 0; i--) {
            uint256 c = _accountFactionStatus[user][factionId]._accountKCIndex[i-1];
            if (c <= chapter) return _accountFactionStatus[user][factionId]._accountKC[c];
        }
        return 0;
    }

    function claimBonus() public override returns (uint256) {
        uint256 time = getTimestamp();
        uint256 bonus = updateBonus();
        emit ClaimBonus(msg.sender, bonus, time);
        return bonus;
    }

    function updateBonus() public override returns (uint256) {
        uint256 bonus;
        uint256 chapter = _accountGlobalInfo[msg.sender]._bonusChapter;
        uint256 endChapter;
        if (_chapterStatus[_chapter]._isEnd) endChapter = _chapter;
        else if (_chapter > 0) endChapter = _chapter - 1;

        if (endChapter > chapter) {
            for (uint256 fi; fi < _accountGlobalInfo[msg.sender]._factionArr.length; fi++) {
                uint256 factionId = _accountGlobalInfo[msg.sender]._factionArr[fi];
                initFactionChapterKC(factionId);
                Faction storage faction = _factionStatus[factionId];

                uint256 endChapter2 = faction._lastCheckChapter < faction._lastIndexChapter
                    ? faction._lastCheckChapter
                    : faction._lastIndexChapter;
                //if (endChapter2 > endChapter) endChapter2 = endChapter;

                bool lastTimeChapterIsNotFinish;
                if (chapter < _accountFactionStatus[msg.sender][factionId]._lastCheckChapter) lastTimeChapterIsNotFinish = true;

                if (lastTimeChapterIsNotFinish) {
                    uint256 index00 = _factionStatus[factionId]._index[chapter];
                    uint256 index01 = _factionStatus[factionId]._index[chapter + 1];
                    bonus = ((index01 - index00) * getAccountKC(msg.sender, factionId, chapter)) / _BASE;
                    chapter++;
                }

                uint256 index0 = _factionStatus[factionId]._index[chapter];
                uint256 index1 = _factionStatus[factionId]._index[chapter + 1];
                uint256 index2 = _factionStatus[factionId]._index[endChapter2];
                if (index1 == 0) index1 = index0;
                console.log("updateBonus1", chapter, endChapter2);
                console.log("updateBonus2", index0, index1, index2);
                console.log(
                    "updateBonus3",
                    getAccountKC(msg.sender, factionId, chapter),
                    getAccountKC(msg.sender, factionId, chapter + 1)
                );
                uint256 bonus0 = ((index1 - index0) * getAccountKC(msg.sender, factionId, chapter)) / _BASE;
                uint256 bonus1 = ((index2 - index1) * getAccountKC(msg.sender, factionId, chapter + 1)) / _BASE;

                bonus = bonus + bonus0 + bonus1;
                //console.log("bonus", bonus0, bonus1);
                if (faction._captain == msg.sender && faction._captainBonus != 0) {
                    bonus = bonus + faction._captainBonus;
                    faction._captainBonus = 0;
                }
            }
            _accountGlobalInfo[msg.sender]._bonusChapter = endChapter;
            console.log("updateBonus4", msg.sender, _accountGlobalInfo[msg.sender]._bonusChapter);
        }

        if (bonus != 0) {
            _kakiToken.transfer(msg.sender, bonus);
        }
        console.log("updateBonus", endChapter, chapter, bonus);
        return bonus;
    }

    function calKc(uint256 kcRation, uint256 v) internal view returns (uint256) {
        uint256 time = getTimestamp();
        uint256 deltaTime = _weekTime - (time - _chapterStatus[_chapter]._startTime);
        uint256 kc = (kcRation * v * deltaTime) / _weekTime / _BASE;
        return kc;
    }

    function calAccountKCInWholeCycle(uint256 factionId) internal view returns (uint256) {
        uint256 accountKC = calAllKcInWholeCycle(factionId, _accountFactionStatus[msg.sender][factionId]._stakeAmount);
        if (_factionStatus[factionId]._captain == msg.sender) {
            accountKC = accountKC + _captionKC;
        }
        return accountKC;
    }

    function calAllKcInWholeCycle(uint256 factionId, mapping(uint256 => uint256) storage stakeAmount)
        internal
        view
        returns (uint256)
    {
        uint256 kcRation = _factionStatus[factionId]._kcAddRatio;
        uint256 kc;
        for (uint256 i; i < _depositTokenSort; i++) {
            if (stakeAmount[i] > 0) kc += ((kcRation * stakeAmount[i] * _tokenFactor[i]) / _BASE) / _BASE;
        }
        return kc;
    }

    function calFactionAllKc(uint256 factionId) internal view returns (uint256) {
        uint256 kc;
        for (uint256 i; i < _depositTokenSort; i++) {
            if (_factionStatus[factionId]._stakeAmount[i] > 0)
                kc += calKc(
                    _factionStatus[factionId]._kcAddRatio,
                    (_factionStatus[factionId]._stakeAmount[i] * _tokenFactor[i]) / _BASE
                );
        }
        return kc;
    }

    function addBonus(uint256 amount) public {
        require(amount > 0, "The amount cannot be 0.");
        _chapterStatus[_chapter + 1]._interest += amount;
    }

    function addNFTFactionBonus(uint256 amount) public {
        require(amount > 0, "The amount cannot be 0.");
        _chapterStatus[_chapter + 1]._nftFactionInterest += amount;
    }

    function getFactionList() public view override returns (FactionListVO[] memory) {
        uint256 time = getTimestamp();
        bool isFireDay = false;
        if (_chapterStatus[_chapter]._startTime + _dayTime >= time) isFireDay = true;

        FactionListVO[] memory listVo = new FactionListVO[](_nextFactionId - 1);
        for (uint256 i = 1; i < _nextFactionId; i++) {
            listVo[i - 1] = generateFactionData(i, isFireDay);
        }

        return listVo;
    }

    function generateFactionData(uint256 factionId, bool isFireDay) internal view returns (FactionListVO memory) {
        FactionListVO memory vo;
        vo._id = factionId;
        vo._captain = _factionStatus[factionId]._captain;
        vo._members = _factionStatus[factionId]._accountArr.length;
        vo._winFireCnt = _factionStatus[factionId]._winFireCnt;
        vo._totalFireCnt = _factionStatus[factionId]._totalFireCnt;
        vo._totalBonus = _factionStatus[factionId]._totalBonus;
        vo._nftId = _factionStatus[factionId]._nftId;

        uint256 lastCheckChapter = _factionStatus[factionId]._lastCheckChapter;
        if (lastCheckChapter == _chapter) {
            if (isFireDay) {
                if (_factionStatus[factionId]._totalChapterKC[_chapter - 1] == 0) {
                    vo._totalkc = _factionStatus[factionId]._chapterKC[_chapter - 1];
                } else {
                    vo._usedkc =
                        _factionStatus[factionId]._totalChapterKC[_chapter - 1] -
                        _factionStatus[factionId]._chapterKC[_chapter - 1];
                    vo._totalkc = _factionStatus[factionId]._totalChapterKC[_chapter - 1];
                }
            } else {
                vo._totalkc = _factionStatus[factionId]._chapterKC[_chapter];
            }
        } else {
            vo._totalkc = _captionKC + calAllKcInWholeCycle(factionId, _factionStatus[factionId]._stakeAmount);
        }

        for (uint256 i; i < _depositTokenSort; i++) {
            vo._stakeAmount[i] = _factionStatus[factionId]._stakeAmount[i];
            if (vo._captain != address(0))
                vo._captionStakeAmount[i] = _accountFactionStatus[vo._captain][factionId]._stakeAmount[i];
        }
        return vo;
    }

    function getFactionData(uint256 factionId) public view override returns (FactionListVO memory) {
        uint256 time = getTimestamp();
        bool isFireDay = false;
        if (_chapterStatus[_chapter]._startTime + _dayTime >= time) isFireDay = true;
        return generateFactionData(factionId, isFireDay);
    }

    function getRoundStartTime(uint256 chapter, uint256 round) public view override returns (uint256) {
        return _chapterStatus[chapter]._roundStartTime[round];
    }

    function getRoundPrice(uint256 chapter, uint256 round) public view override returns (uint256, uint256) {
        return (_poolState[_chapter][_lastRound]._answer, _poolState[_chapter][_lastRound + 1]._answer);
    }

    function getCurrentChapterBonus(uint256 factionId)
        public
        view
        override
        returns (CurrentChapterBonusVO memory, CurrentChapterBonusVO memory)
    {
        CurrentChapterBonusVO memory bonus1;
        CurrentChapterBonusVO memory bonus2;
        uint256 wkc;
        uint256[]  memory roundList = _factionStatus[factionId]._lastFireRound[_chapter];
        for (uint256 i; i < roundList.length; i++) {
            wkc += getRoundWinnerKc(factionId, _chapter, roundList[i]);
        }
        address caption = _factionStatus[factionId]._captain;
        uint256 accountKc = getAccountKC(msg.sender, factionId, _chapter - 1);
        uint256 factionKC = _factionStatus[factionId]._totalChapterKC[_chapter - 1];
        uint256 captionKc = msg.sender == caption ? accountKc : getAccountKC(caption, factionId, _chapter - 1);
        if (_chapterStatus[_chapter]._isEnd && _chapterStatus[_chapter]._winnerKC > 0) {
            uint256 teamBonus1 = (_chapterStatus[_chapter]._interest * wkc) / _chapterStatus[_chapter]._winnerKC;
            uint256 captainBonus1 = (teamBonus1 * _captainRateLimit) / _BASE;
            uint256 kakiFound1 = (teamBonus1 * _kakiFoundationRate) / _BASE;
            uint256 teamBonus2;
            if(_chapterStatus[_chapter]._nftFactionWKC>0)
                teamBonus2 = (_chapterStatus[_chapter]._nftFactionInterest * wkc) / _chapterStatus[_chapter]._nftFactionWKC;
            uint256 captainBonus2 = (teamBonus2 * _captainRateLimit) / _BASE;
            uint256 kakiFound2 = (teamBonus2 * _kakiFoundationRate) / _BASE;
            bonus1._spaceShipBonus = teamBonus1 - kakiFound1;
            bonus1._captionBonus = captainBonus1 + (teamBonus1 - kakiFound1 - captainBonus1) * captionKc / factionKC;
            bonus1._crewBonus = bonus1._spaceShipBonus - bonus1._captionBonus;

            bonus2._spaceShipBonus = teamBonus2 - kakiFound2;
            bonus2._captionBonus = captainBonus2 + (teamBonus2 - kakiFound2 - captainBonus2) * captionKc / factionKC;
            bonus2._crewBonus = bonus2._spaceShipBonus - bonus2._captionBonus;
            if (caption == msg.sender) {
                bonus1._myBonus = bonus1._captionBonus;
                bonus2._myBonus = bonus2._captionBonus;
            } else {
                bonus1._myBonus = (teamBonus1 - kakiFound1 - captainBonus1) * accountKc / factionKC;
                bonus2._myBonus = (teamBonus2 - kakiFound2 - captainBonus1) * accountKc / factionKC;
            }
        }
        return (bonus1, bonus2);
    }

    function getFactionFireData(
        uint256 factionId,
        uint256 chapter,
        uint256 round
    ) public view returns (FirePool memory) {
        return _factionStatus[factionId]._fire[chapter][round];
    }

    function getFactionWinKC(uint256 factionId, uint256 chapter) public view returns (uint256) {
        return _factionStatus[factionId]._factionWinnerKC[chapter];
    }

    function getAccountFactionIds(address account) public view returns (uint256[] memory) {
        return _accountGlobalInfo[account]._factionArr;
    }

    function getStakeAmountInFaction(address account, uint256 factionId)
        public
        view
        returns (uint256[] memory stakeArr)
    {
        stakeArr = new uint256[](_depositTokenSort);
        for (uint256 i; i < _depositTokenSort; i++) {
            stakeArr[i] = (_factionStatus[factionId]._stakeAmount[i]);
        }
    }

    function getDataForRobot()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 lastTotalFire;
        if (_lastRound > 0)
            lastTotalFire = _poolState[_chapter][_lastRound - 1]._call + _poolState[_chapter][_lastRound - 1]._put;
        uint256 totalFire = _poolState[_chapter][_lastRound]._call + _poolState[_chapter][_lastRound]._put;
        return (
            block.timestamp,
            _chapter,
            _lastRound,
            _chapterStatus[_chapter]._startTime,
            _chapterStatus[_chapter]._isEnd,
            _chapterStatus[_chapter]._roundStartTime[_lastRound],
            lastTotalFire,
            totalFire
        );
    }

    /*
     * Get current time
     * @return Current time
     */
    function getTimestamp() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function version() public pure returns (uint256) {
        return 16;
    }
}
