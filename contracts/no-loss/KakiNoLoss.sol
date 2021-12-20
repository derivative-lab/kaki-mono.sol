// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

import "./IAggregatorInterface.sol";
import "./IKakiNoLoss.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/WithAdminRole.sol";
import "hardhat/console.sol";


contract KakiNoLoss is WithAdminRole, IKakiNoLoss {
    uint256 internal constant _BASE = 1000;
    uint256 internal constant _DEPOSIT_TOKEN_SORT = 4;
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
        uint256 _lastIndexChapter;
        uint256[_DEPOSIT_TOKEN_SORT] _stakeAmount;
        uint256 _totalIndex;
        mapping(uint256 => uint256) _index;
        mapping(uint256 => uint256[]) _lastFireRound;
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
        uint256[_DEPOSIT_TOKEN_SORT] _stakeAmount;
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
        _captionKC = 100 ether;

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

        
        initAccountChapterKcInner(_nextFactionId,_chapter,captionKc);
        _accountFactionStatus[msg.sender][_nextFactionId]._lastCheckChapter = _chapter;

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
        uint256 lastCheckChapter=_factionStatus[factionId]._lastCheckChapter;
        if (lastCheckChapter != _chapter) {
            updateFactionWinnerAmount(factionId, lastCheckChapter);
            if(_factionStatus[factionId]._factionWinnerKC[lastCheckChapter]>0)
                updateFactionIndex(factionId,lastCheckChapter);
            _factionStatus[factionId]._chapterKC[_chapter] =
                _captionKC +
                calAllKcInWholeCycle(_factionStatus[factionId]._stakeAmount);

            _factionStatus[factionId]._lastCheckChapter = _chapter;
        }
    }

    function updateFactionIndex(uint256 factionId,uint256 chapter) internal {
        Faction storage fa = _factionStatus[factionId];
        uint256 factionWinnerKC = fa._factionWinnerKC[chapter];
        uint256 totalChapterKC = fa._chapterKC[chapter];
        uint256 teamBonus = _interest[chapter] * factionWinnerKC / _winnerKC[chapter];
        console.log('updateFactionIndex1',_interest[chapter],factionWinnerKC,_winnerKC[chapter]);
        console.log('updateFactionIndex2',teamBonus,totalChapterKC);
        if(_captainRateLimit != 0 || _kakiFoundationRate != 0) {
            uint256 captainBonus = teamBonus * _captainRateLimit /_BASE;
            uint256 kakiFoundationBonus = teamBonus * _kakiFoundationRate /_BASE ;
            teamBonus = teamBonus-captainBonus -kakiFoundationBonus;
            if(captainBonus != 0) {
                if(fa._captain == address(0)) kakiFoundationBonus += captainBonus;
                else _factionStatus[factionId]._captainBonus +=captainBonus;
            }

            if(kakiFoundationBonus != 0) {
                _kakiToken.transfer(_kakiFoundationAddress, kakiFoundationBonus);
            }
        }
        console.log('updateFactionIndex3',teamBonus,totalChapterKC);
        _factionStatus[factionId]._totalIndex += teamBonus *_BASE /totalChapterKC;
        _factionStatus[factionId]._index[chapter] = _factionStatus[factionId]._totalIndex;
        _factionStatus[factionId]._lastIndexChapter=chapter;
        console.log('updateFactionIndex',chapter,_factionStatus[factionId]._totalIndex);
    }

    /**
        更新lastCheckChpater后面chapter的_accountKC ,通过index计算bonus时使用           
    */
    function initAccountChapterKcInner(uint256 factionId,uint256 chapter,uint256 kc)internal {
        _accountFactionStatus[msg.sender][factionId]._accountKC[chapter] = kc;
        _accountFactionStatus[msg.sender][factionId]._accountKCIndex.push(chapter);
        
    }

    function initAccountChapterKC(uint256 factionId) internal {
        uint256 lastCheckChpater=_accountFactionStatus[msg.sender][factionId]._lastCheckChapter;
        if (lastCheckChpater!=0 && lastCheckChpater != _chapter) {
            uint256[_DEPOSIT_TOKEN_SORT] memory stakeAmount = _accountFactionStatus[msg.sender][factionId]._stakeAmount;
            uint256 accountKC = calAccountKCInWholeCycle(factionId);
            _accountFactionStatus[msg.sender][factionId]._lastCheckKC = accountKC;            
            _accountFactionStatus[msg.sender][factionId]._accountKC[_chapter] = accountKC;
            _accountFactionStatus[msg.sender][factionId]._lastCheckChapter = _chapter;
            /** 计算lastCheckChpater 后面chapter的kc值 */
            if(_chapter>lastCheckChpater+1){
                initAccountChapterKcInner(factionId,lastCheckChpater+1,accountKC);
            }
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
        initAccountChapterKcInner(factionId,_chapter,_accountFactionStatus[msg.sender][factionId]._accountKC[_chapter]+addKc);

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
        updateBonus();
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
                calAllKcInWholeCycle(_factionStatus[factionId]._stakeAmount);
        } else {
            _factionStatus[factionId]._chapterKC[_chapter] -= _accountFactionStatus[msg.sender][factionId]._lastCheckKC;
        }
        _factionStatus[factionId]._lastCheckChapter = _chapter;
        delete _accountFactionStatus[msg.sender][factionId];

        delAccountFaction(factionId);
        if (_factionStatus[factionId]._captain == msg.sender) _factionStatus[factionId]._captain = address(0);

        uint256 bonus = updateBonus();
        //if (bonus > 0) _kakiToken.transfer(msg.sender, bonus);

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

    function isRoundFire(uint256 factionId,uint256 chapter,uint256 round) public view returns (bool) {
        return _factionStatus[factionId]._fire[chapter][round]._call > 0 ||
            _factionStatus[factionId]._fire[chapter][round]._put > 0;
    }
    function fire(
        uint256 factionId,
        uint256 amount,
        bool binary
    ) public {
        uint256 _time = getTimestamp();
        uint256 lastCheckChpater=_factionStatus[factionId]._lastCheckChapter;
        bool hasRoundFire = isRoundFire(factionId,_chapter,_lastRound);
        console.log('has round fire ',_lastRound,hasRoundFire);
        require(amount > 0, "The amount cannot be 0.");
        require(_chapterStartTime[_chapter] + _dayTime >= _time, "The trading day has ended.");
        require(_factionStatus[factionId]._captain == msg.sender, "The function caller must be the captain.");
        if (_factionStatus[factionId]._lastCheckChapter != _chapter) {
            initFactionChapterKC(factionId);
            if(_chapter>lastCheckChpater+1)
                _factionStatus[factionId]._chapterKC[_chapter-1] = _factionStatus[factionId]._chapterKC[_chapter];
            _factionStatus[factionId]._totalChapterKC[_chapter-1] = _factionStatus[factionId]._chapterKC[_chapter-1];
        } else {
            if (!hasRoundFire) updateFactionWinnerAmount(factionId, _chapter);
        }
        require(
            _factionStatus[factionId]._chapterKC[_chapter-1] >= amount,
            "The number of KC used cannot be greater than the number of remaining KC."
        );

        if (binary) {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._call += amount;
            _poolState[_chapter][_lastRound]._call += amount;
        } else {
            _factionStatus[factionId]._fire[_chapter][_lastRound]._put += amount;
            _poolState[_chapter][_lastRound]._put += amount;
        }

        _factionStatus[factionId]._chapterKC[_chapter - 1] = _factionStatus[factionId]._chapterKC[_chapter - 1] - amount;
        uint256 len=_factionStatus[factionId]._lastFireRound[_chapter].length;
        if(len==0 || _factionStatus[factionId]._lastFireRound[_chapter][len-1]!=_lastRound)
            _factionStatus[factionId]._lastFireRound[_chapter].push( _lastRound);
        emit Fire(msg.sender, _chapter, _lastRound, factionId, amount, binary, _time);
    }

    function addLoot() public {
        uint256 _time = getTimestamp();
        require(_chapterStartTime[_chapter] + _weekTime <= _time, "The _chapter is not over.");

        /** _lastRound初始2 在一回下单要结算前面2回合的wkc*/
        _lastRound = 2;
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
        console.log('battleDamage',_chapter,_winnerKC[_chapter]);

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

    function getRoundWinnerKc(uint256 factionId,uint256 chapter,uint256 round) view internal returns (uint256) {
        if (
            _poolState[chapter][round + 1]._answer <
            _poolState[chapter][round + 2]._answer
        ) return  _factionStatus[factionId]._fire[chapter][round]._call;
        if (
            _poolState[chapter][round + 1]._answer >
            _poolState[chapter][round + 2]._answer
        ) return _factionStatus[factionId]._fire[chapter][round]._put;
        return 0;
    }

    function updateFactionWinnerAmount(uint256 factionId, uint256 factionChapter) internal {
        uint256 fireLen= _factionStatus[factionId]._lastFireRound[factionChapter].length; 
        uint256 winner;
        if(factionChapter == _chapter){
            /**当前回合下单 计算lastRound-2的wkc */            
            winner+=getRoundWinnerKc(factionId,factionChapter,_lastRound - 2);
            /**如果前一回合没有下单 还需要计算lastRound-3的wkc */    
            if(fireLen>1 && _factionStatus[factionId]._lastFireRound[factionChapter][fireLen-2] < _lastRound - 1
                && isRoundFire(factionId,factionChapter,_lastRound-3))
            {
                winner+=getRoundWinnerKc(factionId,factionChapter,_lastRound - 3);
            }
            
        }else{
            if(fireLen>0){
                uint256 lastRound=_factionStatus[factionId]._lastFireRound[factionChapter][fireLen-1];
                winner+=getRoundWinnerKc(factionId,factionChapter,lastRound);
                /**如果最后一个回合和前一回合至少间隔一回合不需要结算
                否则前一回合还没结算，需要进行结算*/
                console.log('updateFactionWinnerAmount',lastRound,fireLen);
                if(fireLen>1 && _factionStatus[factionId]._lastFireRound[factionChapter][fireLen-2] == lastRound - 1
                    && isRoundFire(factionId,factionChapter,lastRound-1))
                    winner+=getRoundWinnerKc(factionId,factionChapter,lastRound-1);
            }
        }
        _factionStatus[factionId]._factionWinnerKC[factionChapter] += winner;
        console.log("updateFactionWinnerAmount",_lastRound,_factionStatus[factionId]._factionWinnerKC[factionChapter] );
    }

    function getAccountKC(uint256 factionId, uint256 chapter) view internal returns (uint256) {
        uint256 len = _accountFactionStatus[msg.sender][factionId]._accountKCIndex.length;
        /**如果chapter 大于有记录的chapter值 ，通过计算全周期的质押量得到kc
           否则遍历_accountKCIndex ，从大到小获取存储的周期值(c)，当chapter 大于c，返回值
         */
        if(chapter>_accountFactionStatus[msg.sender][factionId]._accountKCIndex[len-1]){
            return calAccountKCInWholeCycle(factionId);
        }
        for (uint256 i = len - 1; i >= 0; i--) {
            uint256 c = _accountFactionStatus[msg.sender][factionId]._accountKCIndex[i];
            if (c <= chapter) return _accountFactionStatus[msg.sender][factionId]._accountKC[c];
        }
        return 0;
    }

    function claimBonus() public returns (uint256) {
        uint256 time = getTimestamp();
        uint256 bonus = updateBonus();
        emit ClaimBonus(msg.sender, bonus,time);
       
    }

    function updateBonus() public returns (uint256) {
        uint256 bonus;
        uint256 chapter=_accountFactionInfo[msg.sender]._bonusChapter;
        for (uint256 fi; fi < _accountFactionInfo[msg.sender]._factionArr.length; fi++) {
            uint256 factionId = _accountFactionInfo[msg.sender]._factionArr[fi];
            initFactionChapterKC(factionId);            
            Faction storage faction = _factionStatus[factionId];
            /**_lastCheckChapter 当前chapter没有结束 */
            uint256 endChapter=faction._lastCheckChapter<_chapter ? faction._lastCheckChapter:faction._lastIndexChapter;
            uint256 index0=_factionStatus[factionId]._index[chapter];
            uint256 index1=_factionStatus[factionId]._index[chapter+1];
            uint256 index2=_factionStatus[factionId]._index[endChapter];
            if(index1==0)
                index1=index0;
            console.log('updateBonus1',chapter,endChapter);
            console.log('updateBonus2',index0,index1,index2);
            console.log('updateBonus3',getAccountKC(factionId, chapter),getAccountKC(factionId, chapter+1));
            uint256 bonus0=(index1-index0)*getAccountKC(factionId, chapter) / _BASE;
            uint256 bonus1=(index2-index1)*getAccountKC(factionId, chapter+1) / _BASE;
            
            bonus=bonus+bonus0+bonus1;
            if (faction._captain == msg.sender && faction._captainBonus != 0) {
                bonus = bonus + faction._captainBonus;
                faction._captainBonus = 0;
            }
        }
        _accountFactionInfo[msg.sender]._bonusChapter = _chapter;
         if (bonus != 0) {
            _kakiToken.transfer(msg.sender, bonus);            
        }
        console.log('updateBonus',bonus);
        return bonus;
    }

    function calKc(uint256 v) internal view returns (uint256) {
        uint256 time = getTimestamp();
        uint256 deltaTime = _weekTime - (time - _chapterStartTime[_chapter]);
        uint256 kc = (v * deltaTime) / _weekTime;
        return kc;
    }

    function calAccountKCInWholeCycle(uint256 factionId)internal view returns (uint256) {
        uint256 accountKC = calAllKcInWholeCycle(_factionStatus[factionId]._stakeAmount);
        if (_factionStatus[factionId]._captain == msg.sender) {
            accountKC = accountKC + _captionKC;
        }
        return accountKC;
    }

    function calAllKcInWholeCycle(uint256[_DEPOSIT_TOKEN_SORT] memory stakeAmount) internal view returns (uint256) {
        uint256 kc;
        uint256 len = stakeAmount.length;
        for (uint256 i; i < len; i++) {
            kc += stakeAmount[i] * _tokenFactor[i];
        }
        return kc;
    }

    function calFactionAllKc(uint256[_DEPOSIT_TOKEN_SORT] memory stakeAmount) internal view returns (uint256) {
        uint256 kc;
        uint256 len =  stakeAmount.length;
        for (uint256 i; i <len; i++) {
            kc += calKc(stakeAmount[i] * _tokenFactor[i]);
        }
        return kc;
    }

    function addBonus(uint256 amount) public{
        require(amount > 0, "The amount cannot be 0.");
        _interest[_chapter]+=amount;
    }

    /*
     * Get current time
     * @return Current time
     */
    function getTimestamp() public view virtual returns (uint256) {
        return block.timestamp;
    }
}
