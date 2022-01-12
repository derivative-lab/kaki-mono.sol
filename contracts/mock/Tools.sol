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

    function version() public pure returns (uint256) {
        return 1;
    }
}
