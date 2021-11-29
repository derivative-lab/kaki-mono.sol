// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

// import "abdk-libraries-solidity/ABDKMath64x64.sol";

// import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

library RandomUtil {
    using SafeMathUpgradeable for uint256;

    function randomSeededMinMax(
        uint256 min,
        uint256 max,
        uint256 seed
    ) internal pure returns (uint256) {
        // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint256 diff = max.sub(min).add(1);
        uint256 randomVar = uint256(keccak256(abi.encodePacked(seed))).mod(diff);
        randomVar = randomVar.add(min);
        return randomVar;
    }

    function combineSeeds(uint256 seed1, uint256 seed2) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed1, seed2)));
    }

    function combineSeeds(uint256[] memory seeds) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seeds)));
    }

    // function plusMinus10PercentSeeded(uint256 num, uint256 seed) internal pure returns (uint256) {
    //     uint256 tenPercent = num.div(10);
    //     return num.sub(tenPercent).add(randomSeededMinMax(0, tenPercent.mul(2), seed));
    // }

    // function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
    //     if (_i == 0) {
    //         return "0";
    //     }
    //     uint256 j = _i;
    //     uint256 len;
    //     while (j != 0) {
    //         len++;
    //         j /= 10;
    //     }
    //     bytes memory bstr = new bytes(len);
    //     uint256 k = len - 1;
    //     while (_i != 0) {
    //         bstr[k--] = bytes1(uint8(48 + (_i % 10)));
    //         _i /= 10;
    //     }
    //     return string(bstr);
    // }
}
