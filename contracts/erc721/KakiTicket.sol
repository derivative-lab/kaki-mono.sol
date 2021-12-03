// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IkakiTicket.sol";
import "../base/BaseERC721.sol";
contract KakiTicket is IkakiTicket, BaseERC721 {

    function initialize() public initializer{
        __BaseERC721_init("", "");
    }

    function mint(
        address _to
    ) external override restricted {
        //_mint(_to);
    }
}
