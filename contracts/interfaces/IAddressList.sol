// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title Implementation of the  draw sign-up list.
 */
interface IAddressList {
    function isInAddressList(address account) external view returns (bool isIn);

    function length() external view returns (uint256 length);

    function addressAt(uint256 index) external view returns (address addr);

    function addressRange(uint256 from, uint256 to) external view returns (address[] memory addresses);
}
