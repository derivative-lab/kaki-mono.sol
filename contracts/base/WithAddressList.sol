// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

import "../interfaces/IAddressList.sol";
import "./WithAdminRole.sol";

contract WithAddressList is WithAdminRole {
    IAddressList public _addressList;
    bool public _needAddressList;

    function __WithAllowList_init(IAddressList addressList, bool needAddressList) internal initializer {
        __WithAdminRole_init();
        __WithAllowList_unchained(addressList, needAddressList);
    }

    function __WithAllowList_unchained(IAddressList addressList, bool needAddressList) internal initializer {
        _needAddressList = needAddressList;
        _addressList = addressList;
    }

    modifier checkIsInAddressList() {
        _checkInAddressList();
        _;
    }

    function _checkInAddressList() internal view virtual {
        if (_needAddressList) {
            require(_addressList.isInAddressList(msg.sender), "Not in list");
        }
    }

    function setIsNeedAddressList(bool isNeed) public restricted {
        _needAddressList = isNeed;
    }

    function setAddressList(IAddressList addressList) public restricted {
        _addressList = addressList;
    }

    function isInAddressList(address account) public view returns (bool) {
        return _addressList.isInAddressList(account);
    }
}
