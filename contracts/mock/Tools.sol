pragma solidity ^0.8.0;

import "../base/WithAdminRole.sol";

import {IVault} from "../interfaces/IVault.sol";
import {IFairLaunch} from "../interfaces/IFairLaunch.sol";
import "../interfaces/IERC20.sol";

contract Tools is WithAdminRole {
    function initialize() public initializer {
        __WithAdminRole_init();
    }

    function approve(IVault vault) public {
        IERC20(address(vault)).approve(address(this), type(uint256).max);
    }

    function deposit(
        IVault vault,
        uint256 amount,
        bool isNative
    ) public {
        vault.deposit{value: isNative ? amount : 0}(amount);
    }

    function withdraw(IVault vault, uint256 amount) public {
        vault.withdraw(amount);
    }

    function depositAndWithdraw(
        IVault vault,
        uint256 amount,
        bool isNative
    ) public {
        deposit(vault, amount, isNative);
        withdraw(vault, amount);
    }

    function version() public pure returns (uint256) {
        return 3;
    }
}
