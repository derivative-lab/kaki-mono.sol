// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/ICaptainClaim.sol";
import "../interfaces/IKakiCaptain.sol";
import "../base/WithRandom.sol";
import "../base/BaseERC721.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IAddressList.sol";
import "../interfaces/IMysteryBox.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CaptainClaim is ICaptainClaim, WithRandom, WithAdminRole {
    mapping(address => bool) _claim;
    mapping(address => uint256) _claimTimeLimit;
    mapping(address => uint256) _mintTimeLimit;

    IERC20 _busd;
    IKakiCaptain public _captain;
    IMysteryBox public _mysBox;
    // IAddressList _addressList;
    // IAddressList _mintList;

    bool _able;
    bool _switchAble;
    uint256[] tokenIdList;
    uint256 public _count;
    uint256 public _limit;
    uint256 public _mintPrice;
    uint256 public _mintLimit;
    uint256 public _claimLimit;
    uint256 public _foundationRate;
    address public _kakiFoundation;
    address constant BlackHole = 0x0000000000000000000000000000000000000000;

    modifier onlyNoneContract() {
        require(msg.sender == tx.origin, "only non contract call");
        _;
    }

    receive() external payable {}

    function initialize(IKakiCaptain capAdd, IMysteryBox mysBoxAdd, IRandoms radomAdd) public initializer {
        __WithAdminRole_init();
        __WithRandom_init(radomAdd);
        _captain = capAdd;
        _mysBox = mysBoxAdd;
        _mintPrice = 0.5 ether;
        _claimLimit = 1;
        _mintLimit = 1;
        _limit = 200;
        _kakiFoundation = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d; // kaki foundation address
    }

    modifier isAble() {
        require(!_able, "Lock is enabled.");
        _;
    }

    modifier isSwitchAble() {
        require(!_switchAble, "Claim had ended.");
        _;
    }

    // function claim() public override isClaimOver onlyNoneContract {
    //     require(_addressList.isInAddressList(msg.sender), "Not allow.");
    //     require(_claimTimeLimit[msg.sender] < _claimLimit, "Claim too much.");
    //     uint256 tokenId = getRandId();
    //     uint256 rad = random(1, 3);
    //     _captain.mint(msg.sender, tokenId, rad);
    //     _claimTimeLimit[msg.sender]++;
    //     emit Claim(msg.sender, tokenId);
    // }

    function mint() public override payable isAble onlyNoneContract {
        //require(_mintList.isInAddressList(msg.sender), "Not allow.");
        require(msg.value == _mintPrice, "BNB not enough");
        require(_count < _limit, "Mint over.");
        require(_mintTimeLimit[msg.sender] < _mintLimit, "Claim too much.");
        uint256 tokenId = getRandId();
        uint256 rad = random(1, 3);
        _captain.mint(msg.sender, tokenId, rad);
        _count++;
        _mintTimeLimit[msg.sender]++;
        emit Mint(msg.sender, tokenId);
    }

    function switchByBox(uint256 boxId) public override isSwitchAble onlyNoneContract {
        _mysBox.safeTransferFrom(msg.sender, address(0xdead), boxId);
        uint256 tokenId = getRandId();
        uint256 rad = random(1, 3);
        _captain.mint(msg.sender, tokenId, rad);
        _count++;
        emit Mint(msg.sender, tokenId);
    }

    function getRandId() internal returns(uint256 tokenId) {
        uint256 tokenIndex = random(0, tokenIdList.length);
        tokenId = tokenIdList[tokenIndex];
        tokenIdList[tokenIndex] = tokenIdList[tokenIdList.length - 1];
        tokenIdList.pop();
    }

    //****************************** view ***************************************** */

    function getList() public view override returns(uint256[] memory idList) {
        idList = tokenIdList;
    }

    function getTotalMint() public view override returns(uint256 count) {
        count = _count;
    }

    //****************************** admin function ***************************************** */
    function setTokenIdList(uint256 start, uint256 end) public onlyOwner {
        for(uint256 i = start; i <= end; i++) {
            tokenIdList.push(i);
        }
    }

    function setTicketPrice(uint256 mintPrice) public onlyOwner {
        _mintPrice = mintPrice;
    }

    function setCapAdd(address capAdd) public onlyOwner {
        _captain = IKakiCaptain(capAdd);
    }

    function setLimit(uint256 newLimit) public onlyOwner {
        _limit = newLimit;
    }

    // function setClaimWhiteList(IAddressList allowList) public onlyOwner {
    //     _addressList = allowList;
    // }

    // function setMintWhiteList(IAddressList mintList) public onlyOwner {
    //     _addressList = mintList;
    // }

    function setSwitchAble() public onlyOwner {
        _switchAble = !_switchAble;
    }

    function setAble() public onlyOwner {
        _able = !_able;
    }

    function setClaimLimit(uint256 newClaimLimit) public onlyOwner {
        require(newClaimLimit > 0, "Invalid limit number");
        _claimLimit = newClaimLimit;
    }

    function setFoundAdd(address newFoundAdd) public onlyOwner {
        require(newFoundAdd != BlackHole, "Invalid address");
        _kakiFoundation = newFoundAdd;
    }

    function sendToFoundation() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _kakiFoundation.call{ value: amount }(new bytes(0));
        require(success, "! safe transfer bnb");
    }

    function version() public pure returns (uint256) {
        return 5;
    }
}