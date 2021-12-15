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
    //******************************************************************** */
    function zapInToken(address from, uint amount, address to) public override {
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(from);
        if (isLP(to)) {
            IPancakePair pair = IPancakePair(to);
            address token0 = pair.token0();
            address token1 = pair.token1();
            // kaki/busd  => kaki-busd       wbnb/kaki => kaki-bnb
            if (from == token0 || from == token1) {
                address other = from == token0 ? token1 : token0;
                _approveTokenIfNeeded(other);
                uint halfAmount = amount / 2;
                uint otherAmount = _swap(from, halfAmount, other, address(this));
                pair.skim(address(this));
                ROUTER.addLiquidity(from, other, amount - halfAmount, halfAmount, 0, 0, msg.sender, block.timestamp);
            } else {
                //wbnb => kaki-busd
                uint bnbAmount = from == WBNB ? _safeSwapToBNB(amount) : _swapTokenForBNB(from, amount, address(this));
                _swapBNBToLp(to, bnbAmount, msg.sender);
            }

        } else {
            _swap(from, amount, to, msg.sender);
        }
    }

    function zapIn(address to) public payable override {
        _swapBNBToLp(to, msg.value, msg.sender);
    }

    function zapOut(address from, uint amount) public override {
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(from);

        if (!isLP(from)) {
            _swapTokenForBNB(from, amount, msg.sender);
        } else {
            IPancakePair pair = IPancakePair(from);
            address token0 = pair.token0();
            address token1 = pair.token1();

            if (pair.balanceOf(from) > 0) {
                pair.burn(address(this));
            }

            if (token0 == WBNB || token1 == WBNB) {
                ROUTER.removeLiquidityETH(token0 != WBNB ? token0 : token1, amount, 0, 0, msg.sender, block.timestamp);
            } else {
                ROUTER.removeLiquidity(token0, token1, amount, 0, 0, msg.sender, block.timestamp);
            }
        }
    }

    //******************************* view ********************************/
    function isLP(address lpToken) public view override returns (bool isLP) {
 
    }
    //******************************* private ********************************/
    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(ROUTER)) == 0) {
            IERC20(token).approve(address(ROUTER), uint(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)); 
        }
    }

    function _swapBNBToLp(address lp, uint amount, address receiver) private {
        if (!isLP(lp)) {
            _swapBNBForToken(lp, amount, receiver);
        } else {
            IPancakePair pair = IPancakePair(lp);
            address token0 = pair.token0();
            address token1 = pair.token1();
            //kaki-wbnb
            if (token0 == WBNB || token1 == WBNB) {
                address token = token0 == WBNB ? token1 : token0;
                uint swapValue = amount / 2;
                uint tokenAmount = _swapBNBForToken(token, swapValue, address(this));
                _approveTokenIfNeeded(token);
                pair.skim(address(this));
                ROUTER.addLiquidityETH{value : amount - swapValue}(token, tokenAmount, 0, 0, receiver, block.timestamp);
            } else {
                //kaki-busd
                uint swapValue = amount / 2;
                uint token0Amount = _swapBNBForToken(token0, swapValue, address(this));
                uint token1Amount = _swapBNBForToken(token1, amount - swapValue, address(this));
                _approveTokenIfNeeded(token0);
                _approveTokenIfNeeded(token1);
                pair.skim(address(this));
                ROUTER.addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, receiver, block.timestamp);
            }
        }
    }

    function _swapBNBForToken(address token, uint amount, address receiver) private returns (uint) {
        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = token;

        uint[] memory amounts = ROUTER.swapExactETHForTokens{value : amount}(0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swapTokenForBNB(address token, uint amount, address receiver) private returns (uint){
        address[] memory path;
        path = new address[](2);
        path[0] = token;
        path[1] = WBNB;

        uint[] memory amounts = ROUTER.swapExactTokensForETH(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length -1];
    }

    function _swap(address from, uint amount, address to, address receiver) private {

    }

    function _safeSwapToBNB(uint amount) private returns (uint) {

    }

    //*************************** admin *********************************** */
    
}