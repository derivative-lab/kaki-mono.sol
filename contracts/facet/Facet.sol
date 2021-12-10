pragma solidity ^0.8.0;

import "../base/WithAdminRole.sol";
import "../interfaces/IERC20.sol";

contract Facet is WithAdminRole {
    mapping(address => mapping(uint256 => uint256)) _facetTimes;
    IERC20 public _token;
    uint256 public _facetLimit;
    uint256 public _facetValue;

    function initialize(IERC20 token) public initializer {
        __WithAdminRole_init();
        _facetLimit = 3;
        _facetValue = 100 ether;
        _token = token;
    }

    function facetBalance() public view returns (uint256 facetBalance, uint256 userBalance) {
        facetBalance = _token.balanceOf(address(this));
        userBalance = _token.balanceOf(msg.sender);
    }

    function facet() public {
        require(_facetTimes[msg.sender][currentDayth()]++ < _facetLimit, "out of limit times today");
        _token.transfer(msg.sender, _facetValue);
    }

    function currentDayth() public view returns (uint256) {
        return block.timestamp / (24 * 3600);
    }

    function version() public pure returns (uint256) {
        return 2;
    }
}
