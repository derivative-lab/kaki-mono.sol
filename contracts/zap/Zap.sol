// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../base/WithAdminRole.sol";
import "./interface/IPancakePair.sol";
import "./interface/IPancakeRouter02.sol";
import "./interface/IZap.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract KakiZap is IZap, WithAdminRole {

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IPancakeRouter02 private constant ROUTER = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    address[] public tokens;
    address public safeSwapBNB;
    mapping(address => bool) private notFlip;

    function initialize() public initializer {
        __WithAdminRole_init();

    }

    receive() external payable {}

    function zapInToken(address _from, uint amount, address _to) public override {
        IERC20(_from).transferfrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from);

        if (isLp(_to)) {
            IPancakePair pair = IPancakePair(_to);
            address token0 = pair.token0();
            address token1 = pair.token1();
            // kaki/busd  => kaki-busd       wbnb/kaki => kaki-bnb
            if (_from == token0 || _from == token1) {
                address other = _from == token0 ? token1 : token0;
                _approveTokenIfNeeded(other);
                uint halfAmount = token0 / 2;
                uint otherAmount = _swap(_from, halfAmount, other, address(this));
                pair.skim(address(this));
                ROUTER.addLiquidity(_from, other, amount - halfAmount, halfAmount, 0, 0, msg.sender, block.timestamp);
            } else {
                //bnb
                uint bnbAmount = _from == WBNB ? _safeSwapToBNB(amount) : _swapTokenForBNB(_from, amount, address(this));
                _swapBNBToLp(_to, bnbAmount, msg.sender);
            }

        } else {
            _swap(_from, amount, _to, msg.sender);
        }
    }


    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(ROUTER)) == 0) {
            IERC20(token).safeApprove(address(ROUTER), uint(- 1));
        }
    }

}