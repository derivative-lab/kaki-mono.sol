// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../base/WithAdminRole.sol";
import "../interfaces/IkakiTicket.sol";

contract KakiCaptainClaim is WithAdminRole {
    using SafeMathUpgradeable for uint256;

    struct Prob {
        uint256 _type;
        uint256 _chip;
        uint256 _probability;
    }

    mapping(uint256 => Prob) _prob;

    IERC20 _kaki;
    IkakiTicket _kakiTicket;

    string[] _uri;
    bool public _able;
    uint256 public _aPrice;
    uint256 public _bPrice;
    uint256 public _count;
    uint256 public _sTicketCount;
    uint256 public _foundationRate;
    address public _squidGameAdd;
    address public _kakiFoundation;

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

    function aBoxOpen() public isAble {
        //精度 10**18
        require(_kaki.balanceOf(msg.sender) >= _aPrice, "Do not have enough kaki token.");
        _kaki.transfer(address(this), _aPrice);
        uint256 rand = getRandom(0, 10);
        _kakiTicket.mint(msg.sender, _count, _uri[rand]);
        _prob[_count]._probability = rand.add(5);
        _prob[_count]._chip = 16;
        _count++;
    }

    function bBoxOpen() public isAble {
        //精度 10**18
        require(_kaki.balanceOf(msg.sender) >= _bPrice, "Do not have enough kaki token.");
        _kaki.transfer(address(this), _bPrice);
        uint256 randTicket = getRandom(1, 100);
        uint256 rand = getRandom(0, 10);

        if (randTicket <= 80) {
            _kakiTicket.mint(msg.sender, _count, _uri[randTicket]);
            _prob[_count]._probability = rand.add(5);
            _prob[_count]._chip = 16;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
        } else if (randTicket > 95 && _sTicketCount < 6) {
            _prob[_count]._type = 2;
            _prob[_count]._probability = 49;
            _prob[_count]._chip = 32;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
            _sTicketCount++;
        } else {
            _prob[_count]._type = 1;
            _prob[_count]._probability = rand.add(10);
            _prob[_count]._chip = 32;
            _kakiTicket.mint(msg.sender, _count, _uri[rand]);
            _count++;
        }
    }

    function combine(uint256[] memory ticket, uint256[] memory captain) public isAble {
        uint256 totalChip = _prob[ticket[0]]._chip.add(_prob[ticket[1]]._chip).add(_prob[ticket[2]]._chip);
        uint256 totalType = _prob[ticket[0]]._type.add(_prob[ticket[1]]._type).add(_prob[ticket[2]]._type);
        require(totalType == 3 && totalChip == 80, "Invalid NFT.");
        require(
            _kakiTicket.ownerOf(ticket[0]) == msg.sender &&
                _kakiTicket.ownerOf(ticket[1]) == msg.sender &&
                _kakiTicket.ownerOf(ticket[2]) == msg.sender,
            "Not NFT owner."
        );
        uint256 totalProb = _prob[ticket[0]]._probability.add(_prob[ticket[1]]._probability).add(
            _prob[ticket[2]]._probability
        );
        require(captain.length <= 3);
        for (uint256 i; i < captain.length; i++) {
            totalProb = totalProb.add(_prob[captain[i]]._probability);
        }

        uint256 rand = getRandom(1, 100);
        if (rand <= totalProb) {
            // _kakiTicket.mint(msg.sender, _count, _uri[]);
            _count++;
        }
        //销毁
    }

    //
    function getRandom(uint256, uint256) internal returns (uint256 rand) {}

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

    function sendToPool(uint256 amount) public isSquidAdd {
        uint256 bonus = amount.mul(_foundationRate).div(100);
        _kaki.transfer(msg.sender, amount.div(bonus));
        _kaki.transfer(_kakiFoundation, bonus);
    }

    function setAble() public onlyOwner {
        _able = !_able;
    }
}
