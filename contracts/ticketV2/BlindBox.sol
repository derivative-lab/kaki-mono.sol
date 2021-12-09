// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../base/WithRandom.sol";
import "../base/WithAdminRole.sol";
import "./interface/IkakiTicket.sol";
import "./interface/IBlindBox.sol";

contract BlindBox is WithAdminRole, IBlindBox, WithRandom {

    IERC20 _kaki;
    IkakiTicket _kakiTicket;
    //IkakiCaptain _kakiCaptain;

    string[] _uri;
    bool _able;
    uint256 _count;
    uint256 _sTicketCount;
    uint256 public _aPrice;
    uint256 public _bPrice;
    uint256 public _sTicketProb;
    uint256 public _commonChip;
    uint256 public _rareChip;
    uint256 public _foundationRate;
    address public _squidGameAdd;
    address public _kakiFoundation;
    address constant blackHole = 0x0000000000000000000000000000000000000000;

    function initialize(IkakiTicket ercAdd, IERC20 kTokenAdd) public initializer {
        __WithAdminRole_init();
        _kaki = kTokenAdd;
        _kakiTicket = ercAdd;
        //_kakiCaptain = ;
        _aPrice = 100 ether;
        _bPrice = 150 ether;
        _commonChip = 16;
        _rareChip = 32;
        _sTicketProb = 49;
        _foundationRate = 30; //3%
        _squidGameAdd = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d; // squid game contract address
        _kakiFoundation = 0x958f0991D0e847C06dDCFe1ecAd50ACADE6D461d; // kaki foundation address
    }

    modifier isAble() {
        require(!_able, "Lock is enabled.");
        _;
    }

    modifier isSquidAdd() {
        require(msg.sender == _squidGameAdd, "Invalid address.");
        _;
    }

    modifier onlyNoneContract() {
        require(msg.sender == tx.origin, "only non contract call");
        _;
    }

    function aBoxOpen() public override isAble {
        require(_kaki.balanceOf(msg.sender) >= _aPrice, "Do not have enough kaki token.");
        _kaki.transferFrom(msg.sender, _squidGameAdd, _aPrice);
        uint256 rand = random(0, 10);
        _kakiTicket.mint(msg.sender, _commonChip, rand + 5, _aPrice, 0);
        emit BuyABox(msg.sender);
    }

    function bBoxOpen() public override isAble {
        require(_kaki.balanceOf(msg.sender) >= _bPrice, "Do not have enough kaki token.");
        _kaki.transferFrom(msg.sender, _squidGameAdd, _bPrice);
        uint256 randTicket = random(1, 100);
        uint256 rand = random(0, 10);

        if (randTicket <= 80) {
            _kakiTicket.mint(msg.sender, _commonChip, rand + 5, _aPrice, 0);
        } else if (randTicket >95 && _sTicketCount < 6) {
            _kakiTicket.mint(msg.sender, _rareChip, _sTicketProb, _bPrice, 2);
            _sTicketCount++;
        } else {
            _kakiTicket.mint(msg.sender, _rareChip, rand + 10, _bPrice, 1);
        }
    }

    function combine(uint256[3] memory ticket, uint256[] memory extraCap) public override isAble onlyNoneContract {
        require(extraCap.length <= 3, "Invalid number of captain.");

        uint256 totalChip;
        uint256 totalType;
        uint256 totalProb;

        for(uint256 i; i < ticket.length; i ++) {
            require(_kakiTicket.ownerOf(ticket[i]) == msg.sender, "Not NFT owner.");
            totalChip += _kakiTicket.getTicketMessage(ticket[i]).chip;
            totalType += _kakiTicket.getTicketMessage(ticket[i]).ticketType;
            totalProb += _kakiTicket.getTicketMessage(ticket[i]).prob;
        }

        uint256 extraProb;

        // for(uint256 i; i < extraCap.length; i ++) {
        //     require(_kakiCaptain.ownerOf(extraCap[i]) == msg.sender, "Not NFT owner.");
        //     extraProb += _kakiCaptain.getTicketMessage(extraCap[i]).prob;
        // }

        require(totalType == 3 && totalChip == 80, "Invalid NFT.");
        uint256 rand = random(1, 100);
        totalProb = totalProb + extraProb;

        if (rand <= totalProb) {
            _kakiTicket.mint(msg.sender, _commonChip, 0, 0, 3);
        }
        
        for (uint256 i; i < 3; i++){
            _kakiTicket.transferFrom(msg.sender, blackHole, ticket[i]);
        }
    }

    //****************************** admin function ***************************************** */
    function setSTicketProb(uint256 newProb) public onlyOwner {
        _sTicketProb = newProb;
    }
    function setABoxPrice(uint256 aPrice) public onlyOwner {
        _aPrice = aPrice;
    }

    function setBBoxPrice(uint256 bPrice) public onlyOwner {
        _bPrice = bPrice;
    }

    function setERC721(address ercAdd) public onlyOwner {
        _kakiTicket = IkakiTicket(ercAdd);
    }

    function setSuperTCount() public onlyOwner {
        _sTicketCount = 0;
    }

    function setAble() public onlyOwner {
        _able = !_able;
    }
}
