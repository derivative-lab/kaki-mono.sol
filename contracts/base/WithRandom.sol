// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./RandomUtil.sol";
import "../interfaces/IRandoms.sol";

contract WithRandom is Initializable {
    IRandoms _randoms;

    function __WithRandom_init(IRandoms randoms) internal initializer {
        __WithRandom_init_unchained(randoms);
    }

    function __WithRandom_init_unchained(IRandoms randoms) internal initializer {
        _randoms = randoms;
    }

    function random(uint256 min, uint256 max) internal view returns (uint256 _randomNumber) {
        uint256 seed = _randoms.getRandomSeed(msg.sender);
        _randomNumber = RandomUtil.randomSeededMinMax(min, max, seed);
    }
}
