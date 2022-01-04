// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IKakiCaptain.sol";
import "../base/BaseERC721.sol";
import "../base/AllowERC721.sol";

contract KakiCaptain is IKakiCaptain, AllowERC721 {
    address public nloAddress;
    uint256 public lowMember;
    uint256 public mediumMember;
    uint256 public highMember;

    uint256 public basicMiningRate;
    uint256 public miningK;
    
    uint256 public lowCombineRate;
    uint256 public mediumCombineRate;
    uint256 public highCombineRate;
    
    uint256[3] member;
    uint256[3] combineRate;
    uint256[30] startId;
    uint256[30] endId;
    uint256[30] mineRate;
    string[3] capName;
    mapping(uint256 => CapPara) _capPara;
    mapping(uint256 => uint256) _capComb;
    mapping(uint256 => CapStatus) _capStatus;

    modifier isNLO() {
        require(msg.sender == nloAddress, "Invalid Address");
        _;
    }

    function initialize() public initializer{
        __BaseERC721_init("", "");
        lowMember = 2;
        mediumMember = 5;
        highMember = 10;

        basicMiningRate = 5;
        miningK = 1;

        lowCombineRate = 20;
        mediumCombineRate = 30;
        highCombineRate = 50;
        
        startId =[1,17,63,121,247,367,443,573,699,811,929,1049,1145,1249,1345,
                1417,1513,1585,1637,1709,1765,1801,1847,1877,1903,1933,1953,1969,1995,2011];
        endId = [16,62,120,246,366,442,572,698,810,928,1048,1144,1248,1344,1416,
                1512,1584,1636,1708,1764,1800,1846,1876,1902,1932,1952,1968,1994,2010,2020];
        mineRate = [basicMiningRate * miningK, basicMiningRate * miningK, basicMiningRate * miningK,
                    basicMiningRate * miningK * 2, basicMiningRate * miningK * 2, basicMiningRate * miningK * 2,
                    basicMiningRate * miningK * 3, basicMiningRate * miningK * 3, basicMiningRate * miningK * 3,
                    basicMiningRate * miningK * 4, basicMiningRate * miningK * 4, basicMiningRate * miningK * 4,
                    basicMiningRate * miningK * 5, basicMiningRate * miningK * 5, basicMiningRate * miningK * 5,
                    basicMiningRate * miningK * 6, basicMiningRate * miningK * 6, basicMiningRate * miningK * 6,
                    basicMiningRate * miningK * 7, basicMiningRate * miningK * 7, basicMiningRate * miningK * 7,
                    basicMiningRate * miningK * 8, basicMiningRate * miningK * 8, basicMiningRate * miningK * 8,
                    basicMiningRate * miningK * 9, basicMiningRate * miningK * 9, basicMiningRate * miningK * 9,
                    basicMiningRate * miningK * 10, basicMiningRate * miningK * 10, basicMiningRate * miningK * 10];

        //!!!!!!!!!!!!!!!!!!!  member = [highMember, lowMember, mediumMember];
        member = [lowMember, mediumMember, highMember];
        combineRate = [lowCombineRate, mediumCombineRate, highCombineRate];
        capName = ["Mate", "Pilot", "Enginner"];

        nloAddress = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d;
    }

    function allowTransfer(uint256 tokenId)
        public
        view
        override
        returns (bool isAllow)
    {
        isAllow = !_capStatus[tokenId].noTransfer;
    }

    function mint(address _to, uint256 _tokenId, uint256 _rad) external override restricted {
        uint256 tokenIdex = totalMinted();
        require(tokenIdex < 2020, "Reach the upper limit.");
        _capComb[_tokenId] = _rad;
        _mint(_to, _tokenId);
    }

    function setCapTransfer(uint256 tokenId) public override isNLO {
        _capStatus[tokenId].noTransfer = !_capStatus[tokenId].noTransfer;
    }

    function setCapCreate(uint256 tokenId) public override isNLO {
        _capStatus[tokenId].noCreateTeam = !_capStatus[tokenId].noCreateTeam;
    }

    //*************************** admin *********************************** */
    function setMember(uint256 newLowMember, uint256 newMediumMember, uint256 newHighMember) public onlyOwner {
        lowMember = newLowMember;
        mediumMember = newMediumMember;
        highMember = newHighMember;
    }

    function setMiningRate(uint256 newBasicMiningRate, uint256 newMiningK) public onlyOwner {
        basicMiningRate = newBasicMiningRate;
        miningK = newMiningK;
    }

    function setCombineRate(uint256 newLowCombineRate, uint256 newMediumCombineRate, uint256 newHighCombineRate) public onlyOwner {
        lowCombineRate = newLowCombineRate;
        mediumCombineRate = newMediumCombineRate;
        highCombineRate = newHighCombineRate;
    }

    //*************************** view *********************************** */
    function getCapType(uint256 tokenId) public override view returns (uint256) {
        uint256 capType;
        for (uint i; i < 30; i++) {
            if(tokenId >= startId[i] && tokenId <= endId[i]) {
                capType = i + 1;
                break;
            }
        }
        return capType;
    }

    function getCapComb(uint256 tokenId) public override view returns (uint256) {
        uint256 capComb;
        capComb = combineRate[_capComb[tokenId] - 1];
        return capComb;
    }

    function getCapInfo(uint256 tokenId) public override view returns (CapPara memory capPara) {
        uint256 capType = getCapType(tokenId);
        uint256 capComb = getCapComb(tokenId);
        capPara.captainType = capType;
        capPara.combineRate = capComb;
        capPara.miningRate = mineRate[capType - 1];
        capType = capType % 3;
        capPara.memberNum = member[capType];

        if (capType <= 14) {
            capPara.capName = capName[0];
        } else if (capType <= 22) {
            capPara.capName = capName[1];
        } else {
            capPara.capName = capName[2];
        }
    }

    function getCapStatus(uint256 tokenId) public override view returns (CapStatus memory capStatus) {
        capStatus = _capStatus[tokenId]; 
    }
}