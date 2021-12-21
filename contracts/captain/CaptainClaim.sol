// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/ICaptainClaim.sol";
import "./interface/IKakiCaptain.sol";
import "../base/WithRandom.sol";
import "../base/BaseERC721.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IAddressList.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CaptainClaim is ICaptainClaim, WithRandom, WithAdminRole {
    mapping(address => bool) _claim;
    mapping(address => uint256) _claimTimeLimit;

    IERC20 _busd;
    IKakiCaptain public _captain;
    IAddressList _addressList;

    string[] _uri;
    bool _able;
    bool _claimAble;
    uint256 _count;
    uint256 public _mintPrice;
    uint256 public _claimLimit;
    uint256 public _invalidTime;
    uint256 public _foundationRate;
    address public _kakiFoundation;
    address constant BlackHole = 0x0000000000000000000000000000000000000000;

    function initialize(IKakiCaptain capAdd, IERC20 busdAdd, uint256 invalidTime, IAddressList allowList) public initializer {
        __WithAdminRole_init();
        _captain = capAdd;
        _busd = busdAdd;
        _addressList = allowList;
        _mintPrice = 0.1 ether;
        _claimLimit = 1;
        _invalidTime = invalidTime;
        _kakiFoundation = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d; // kaki foundation address
    }

    modifier isAble() {
        require(!_able, "Lock is enabled.");
        _;
    }

    modifier isClaimOver() {
        require(!_claimAble, "Claim had ended.");
        _;
    }

    function claim() public override isClaimOver {
        require(_addressList.isInAddressList(msg.sender), "Not allow.");
        require(_claimTimeLimit[msg.sender] < _claimLimit, "Claim too much.");
        _captain.mint(msg.sender);
        _claimTimeLimit[msg.sender]++;
        emit Claim(msg.sender);
    }

    function mint() public override payable isAble {
        (bool sent, ) = address(this).call{value: _mintPrice}(new bytes(0));
        require(sent, "Failed to send Ether");
        _captain.mint(msg.sender);
        emit Mint(msg.sender);
    }

    //****************************** admin function ***************************************** */
    function setTicketPrice(uint256 mintPrice) public onlyOwner {
        _mintPrice = mintPrice;
    }

    function setCapAdd(address capAdd) public onlyOwner {
        _captain = IKakiCaptain(capAdd);
    }

    function setInvalidTime(uint256 newInvalidTime) public onlyOwner {
        _invalidTime = newInvalidTime;
    }

    function setClaimWhiteList(IAddressList allowList) public onlyOwner {
        _addressList = allowList;
    }

    function setClaimAble() public onlyOwner {
        _claimAble = !_claimAble;
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
}