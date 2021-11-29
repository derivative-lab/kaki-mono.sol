// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IAggregatorInterface {
    function latestAnswer() external view returns (uint256);

    function historyAnswer(uint32 startTime, uint32 endTime) external view returns (uint256);
}
