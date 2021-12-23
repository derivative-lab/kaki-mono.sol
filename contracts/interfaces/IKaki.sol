// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface IKaki is IERC20 {
    function mint(address to, uint256 amount) external;
}