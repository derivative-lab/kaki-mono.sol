pragma solidity ^0.8.0;

import "./IERC20.sol";
import {IDebtToken} from "./IDebtToken.sol";

interface IKakiGarden {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event HarvestMany(address indexed user, uint256[] pids, uint256[] amounts);
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        // uint256 rewardTotal;
        uint256 rewardAtBlock; // the last block reward.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 allocPoint;
        uint256 pid;
        uint256 stakingAmount;
        IERC20 token;
        IDebtToken debtToken;
        string name;
    }

    function harvest(uint256 pid) external;

    function harvestMany(uint256[] memory pids) external;

    function withdraw(uint256 pid, uint256 amount) external;

    function deposit(uint256 pid, uint256 amount) external;

    function withdrawAll(uint256 pid) external;
}
