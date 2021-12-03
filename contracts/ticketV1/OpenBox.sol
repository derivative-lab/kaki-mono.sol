// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IBlindBox.sol";
import "./interface/ITicket.sol";
import "./interface/IOpenBox.sol";
import "../base/WithRandom.sol";
import "../base/BaseERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpenBox is IOpenBox, WithRandom, BaseERC721, OwnableUpgradeable {    
    mapping(uint256 => TicketPara) _ticketIsDrop;
    mapping(address => bool) _claim;
    
    IERC20 _busd;
    ITicket _ticket;   
    
    string[] _uri;
    bool _able;
    bool _claimAble;
    uint256 _count;
    uint256 constant BASE = 10**18;
    uint256 public _ticketPrice;
    uint256 public _invalidTime;
    uint256 public _foundationRate;
    address public _squidGameAdd;
    address public _kakiFoundation;
    address constant BlackHole = 0x0000000000000000000000000000000000000000;

    function initialize(address ercAdd, address busdAdd) public initializer {
        __Ownable_init();
        _ticket = ITicket(ercAdd);
        _busd = IERC20(busdAdd);
        _ticketPrice = 100;
        //uri
        _foundationRate = 0;                                         
        _squidGameAdd = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d;   // squid game contract address
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

    modifier isSquidAdd() {
        require(msg.sender == _squidGameAdd, "Invalid address.");
        _;
    }

    function claim() public override isClaimOver {
        require(_claim[msg.sender], "Invalid address");
        uint256 tokenId = totalMinted();
        _ticket.mint(msg.sender, tokenId, _uri[0]);
        _ticketIsDrop[tokenId].isDrop = true;
        _ticketIsDrop[tokenId].invalidTime = _invalidTime;
        _claim[msg.sender] = false;
        _tokenIdTracker.increase();
    }

    function buyTicket() public override isAble {
        require(_busd.balanceOf(msg.sender) >= _ticketPrice * BASE, "Do not have enough BUSD.");
        _busd.transfer(address(this), _ticketPrice * BASE);
        uint256 tokenId = totalMinted();
        _ticket.mint(msg.sender, tokenId, _uri[1]);
        _tokenIdTracker.increase();
    }

    function sendToPool() public override isSquidAdd {
        _busd.transfer(msg.sender, _ticketPrice);
    }

    //*********************************** read ********************************************** */
    function getTicketMessage(uint256 tokenId) public view override returns(TicketPara memory) {
        return (_ticketIsDrop[tokenId]);
    }

    //****************************** admin function ***************************************** */
    function setTicketPrice(uint256 ticketPrice) public onlyOwner {
        _ticketPrice = ticketPrice;
    }

    function setERC721(address ercAdd) public onlyOwner {
        _ticket = ITicket(ercAdd);
    }

    function setInvalidTime(uint256 newInvalidTime) public onlyOwner {
        _invalidTime = newInvalidTime;
    }

    function setClaimWhiteList(address[] memory whiteList) public onlyOwner {
        for (uint256 i; i < whiteList.length; i++) {
            _claim[whiteList[i]] = true;
        }
    }

    function setClaimAble() public onlyOwner {
        _claimAble = !_claimAble;
    }

    function setAble() public onlyOwner {
        _able = !_able;
    }
}