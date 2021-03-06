// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IKakiCaptain.sol";
import "../base/BaseERC721.sol";
import "../base/AllowERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract KakiCaptain is IKakiCaptain, AllowERC721 {
    using Strings for uint256;

    address public nloAddress;
    uint256 public lowMember;
    uint256 public mediumMember;
    uint256 public highMember;

    uint256 public basicMiningRate;
    uint256 public miningK;

    uint256 public lowCombineRate;
    uint256 public mediumCombineRate;
    uint256 public highCombineRate;
    uint256 public constant MaxSupply = 2020;

    uint256[3] public member;
    uint256[3] public combineRate;
    uint256[30] public startId;
    uint256[30] public endId;
    uint256[30] public mineRate;
    string[3] public capName;
    mapping(uint256 => CapPara) public _capPara;
    mapping(uint256 => CapStatus) public _capStatus;

    modifier isNLO() {
        require(msg.sender == nloAddress, "Invalid Address");
        _;
    }

    function initialize() public initializer {
        __BaseERC721_init("KAKIER NFT", "KKR");
        lowMember = 2;
        mediumMember = 5;
        highMember = 10;

        basicMiningRate = 5;
        miningK = 1;

        lowCombineRate = 20;
        mediumCombineRate = 30;
        highCombineRate = 50;

        startId = [
            1,
            17,
            63,
            121,
            247,
            367,
            443,
            573,
            699,
            811,
            929,
            1049,
            1145,
            1249,
            1345,
            1417,
            1513,
            1585,
            1637,
            1709,
            1765,
            1801,
            1847,
            1877,
            1903,
            1933,
            1953,
            1969,
            1995,
            2011
        ];
        endId = [
            16,
            62,
            120,
            246,
            366,
            442,
            572,
            698,
            810,
            928,
            1048,
            1144,
            1248,
            1344,
            1416,
            1512,
            1584,
            1636,
            1708,
            1764,
            1800,
            1846,
            1876,
            1902,
            1932,
            1952,
            1968,
            1994,
            2010,
            2020
        ];
        mineRate = [
            basicMiningRate * miningK,
            basicMiningRate * miningK,
            basicMiningRate * miningK,
            basicMiningRate * miningK * 2,
            basicMiningRate * miningK * 2,
            basicMiningRate * miningK * 2,
            basicMiningRate * miningK * 3,
            basicMiningRate * miningK * 3,
            basicMiningRate * miningK * 3,
            basicMiningRate * miningK * 4,
            basicMiningRate * miningK * 4,
            basicMiningRate * miningK * 4,
            basicMiningRate * miningK * 5,
            basicMiningRate * miningK * 5,
            basicMiningRate * miningK * 5,
            basicMiningRate * miningK * 6,
            basicMiningRate * miningK * 6,
            basicMiningRate * miningK * 6,
            basicMiningRate * miningK * 7,
            basicMiningRate * miningK * 7,
            basicMiningRate * miningK * 7,
            basicMiningRate * miningK * 8,
            basicMiningRate * miningK * 8,
            basicMiningRate * miningK * 8,
            basicMiningRate * miningK * 9,
            basicMiningRate * miningK * 9,
            basicMiningRate * miningK * 9,
            basicMiningRate * miningK * 10,
            basicMiningRate * miningK * 10,
            basicMiningRate * miningK * 10
        ];

        member = [highMember, lowMember, mediumMember];
        combineRate = [highCombineRate, lowCombineRate, mediumCombineRate];
        capName = ["Mate", "Pilot", "Engineer"];

        nloAddress = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d;
    }

    function allowTransfer(uint256 tokenId) public view override returns (bool isAllow) {
        isAllow = !_capStatus[tokenId].noTransfer;
    }

    function mint(address _to, uint256 _tokenId) external override restricted {
        uint256 tokenIdex = totalMinted();
        require(tokenIdex < MaxSupply, "Reach the upper limit.");
        _mint(_to, _tokenId);
        increaceTokenId();
    }

    function setCapTransfer(uint256 tokenId) public override isNLO {
        _capStatus[tokenId].noTransfer = !_capStatus[tokenId].noTransfer;
    }

    function setCapCreate(uint256 tokenId) public override isNLO {
        _capStatus[tokenId].noCreateTeam = !_capStatus[tokenId].noCreateTeam;
        _capStatus[tokenId].noTransfer = !_capStatus[tokenId].noTransfer;
    }

    //*************************** admin *********************************** */

    function setNLOAddress(address nloAdd) public onlyOwner {
        require(nloAdd != address(0), "The address cannot be 0.");
        nloAddress = nloAdd;
    }

    function setMember(
        uint256 newLowMember,
        uint256 newMediumMember,
        uint256 newHighMember
    ) public onlyOwner {
        lowMember = newLowMember;
        mediumMember = newMediumMember;
        highMember = newHighMember;
    }

    function setMiningRate(uint256 newBasicMiningRate, uint256 newMiningK) public onlyOwner {
        basicMiningRate = newBasicMiningRate;
        miningK = newMiningK;
    }

    function setCombineRate(
        uint256 newLowCombineRate,
        uint256 newMediumCombineRate,
        uint256 newHighCombineRate
    ) public onlyOwner {
        lowCombineRate = newLowCombineRate;
        mediumCombineRate = newMediumCombineRate;
        highCombineRate = newHighCombineRate;
    }

    //*************************** view *********************************** */
    function getCapType(uint256 tokenId) public view override returns (uint256) {
        uint256 capType;
        for (uint256 i; i < 30; i++) {
            if (tokenId >= startId[i] && tokenId <= endId[i]) {
                capType = i + 1;
                break;
            }
        }
        return capType;
    }

    function getCapComb(uint256 tokenId) public view override returns (uint256) {
        uint256 capComb;
        capComb = combineRate[tokenId % 3];
        return capComb;
    }

    function getCapInfo(uint256 tokenId) public view override returns (CapPara memory capPara) {
        uint256 capType = getCapType(tokenId);
        capPara.captainType = capType;
        capPara.miningRate = mineRate[capType - 1];
        capPara.memberNum = member[capType % 3];
        capPara.combineRate = combineRate[tokenId % 3];

        if (capType <= 14) {
            capPara.capName = capName[0];
        } else if (capType <= 22) {
            capPara.capName = capName[1];
        } else {
            capPara.capName = capName[2];
        }
    }

    function getCapStatus(uint256 tokenId) public view override returns (CapStatus memory capStatus) {
        capStatus = _capStatus[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseTokenURI;
        string memory path = string(abi.encodePacked(tokenId.toString(), ".json"));
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, path)) : "";
    }

    function version() public pure returns (uint256) {
        return 4;
    }
}
