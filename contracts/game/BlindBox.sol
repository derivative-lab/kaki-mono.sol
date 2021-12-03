// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IkakiTicket.sol";
import "../interfaces/IBlindBox.sol";

contract KakiBlindBox is WithAdminRole, IBlindBox {

    mapping(uint256 => Prob) _prob;

    IERC20 _kaki;
    IkakiTicket _kakiTicket;

    string[] _uri;
    bool _able;
    uint256 _count;
    uint256 _sTicketCount;
    uint256 constant BASE = 10 ** 18;
    uint256 public _aPrice;
    uint256 public _bPrice;
    uint256 public _foundationRate;
    address public _squidGameAdd;
    address public _kakiFoundation;
    address constant blackHole = 0x0000000000000000000000000000000000000000;

    function initialize(address ercAdd, address kTokenAdd) public initializer {
        __WithAdminRole_init();
        _kaki = IERC20(kTokenAdd);
        _kakiTicket = IkakiTicket(ercAdd);
        _aPrice = 100;
        _bPrice = 150;
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
        require(_kaki.balanceOf(msg.sender) >= _aPrice * BASE, "Do not have enough kaki token.");
        _kaki.transfer(address(this), _aPrice * BASE);
        uint256 rand = getRandom(0, 10);
        _kakiTicket.mint(msg.sender, _count, _uri[rand]);
        _prob[_count]._probability = rand + 5;
        _prob[_count]._chip = 16;
        _count++;
        emit BuyABox(msg.sender);
    }

    function bBoxOpen() public override isAble {
        require(_kaki.balanceOf(msg.sender) >= _bPrice * BASE, "Do not have enough kaki token.");
        _kaki.transfer(address(this), _bPrice * BASE);
        uint256 randTicket = getRandom(1, 100);
        uint256 rand = getRandom(0, 10);

        if (randTicket <= 80) {
            _kakiTicket.mint(msg.sender, _count, _uri[randTicket]);
            _prob[_count]._probability = rand + 5;
            _prob[_count]._chip = 16;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
        } else if (randTicket >95 && _sTicketCount < 6) {
            _prob[_count]._type = 2;
            _prob[_count]._probability = 49;
            _prob[_count]._chip = 32;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
            _sTicketCount++;
        } else {
            _prob[_count]._type = 1;
            _prob[_count]._probability = rand + 10;
            _prob[_count]._chip = 32;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
        }
    }

    function combine(uint256[3] memory ticket, uint256 extraCap) public override isAble onlyNoneContract {
        require(extraCap <= 15, "Invalid extra captain.");
        uint256 totalChip = _prob[ticket[0]]._chip + _prob[ticket[1]]._chip + _prob[ticket[2]]._chip;
        uint256 totalType = _prob[ticket[0]]._type + _prob[ticket[1]]._type + _prob[ticket[2]]._type;

        require(totalType == 3 && totalChip == 80, "Invalid NFT.");
        require(_kakiTicket.ownerOf(ticket[0]) == msg.sender && 
                _kakiTicket.ownerOf(ticket[1]) == msg.sender && 
                _kakiTicket.ownerOf(ticket[2]) == msg.sender, 
                "Not NFT owner.");
        uint256 totalProb = _prob[ticket[0]]._probability + _prob[ticket[1]]._probability + _prob[ticket[2]]._probability;
        uint256 rand = getRandom(1, 100);

        totalProb = totalProb + extraCap;
        if (rand <= totalProb) {
            _kakiTicket.mint(msg.sender, _count, _uri[22]);
            _prob[_count]._type = 3;
            _prob[_count]._chip = 16;
            _count++;
        }
        for (uint256 i; i < 3; i++){
            _kakiTicket.transferFrom(msg.sender, blackHole, ticket[i]);
        }
    }
    
    function getRandom(uint256, uint256) internal returns(uint256 rand) {

    }

    function sendToPool(uint256 amount) public isSquidAdd {
        require(_kaki.balanceOf(address(this)) >= amount, "Do not have enough Kaki.");
        uint256 bonus = amount * _foundationRate / 100;
        _kaki.transfer(msg.sender, amount / bonus);
        _kaki.transfer(_kakiFoundation, bonus);
    }

    //*********************************** read ********************************************** */
    function getTicketMessage(uint256 tokenId) public view override returns(Prob memory prob) {
        return (_prob[tokenId]);
    }

    //****************************** admin function ***************************************** */
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
