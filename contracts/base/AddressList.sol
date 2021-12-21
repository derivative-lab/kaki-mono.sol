// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../interfaces/IAddressList.sol";
import "./WithAdminRole.sol";

/**
 * @title Implementation of the   sign-up list.
 */
contract AddressList is Initializable, IAddressList, WithAdminRole {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet _addressList;

    event NewAddress(address indexed account);
    event DeleteAddress(address indexed account);

    function initialize() public initializer {
        __WithAdminRole_init();
    }

    function isInAddressList(address account) public view override returns (bool) {
        return _addressList.contains(account);
    }

    function length() public view override returns (uint256) {
        return _addressList.length();
    }

    function addressAt(uint256 index) public view override returns (address) {
        return _addressList.at(index);
    }

    function addressRange(uint256 from, uint256 to) external view returns (address[] memory addresses) {
        addresses = new address[](to - from);
        for (uint256 i = from; i < to; i++) {
            addresses[i] = addressAt(i);
        }
    }

    // EXTERNAL FUNCTIONS

    function addToAddressList(address[] memory addresses) public restricted {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            require(_addressList.add(addresses[i]), "The address is already in list");
            emit NewAddress(addresses[i]);
        }
    }

    function tryAddAddresses(address[] memory addresses) public restricted {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            if (_addressList.add(addresses[i])) {
                emit NewAddress(addresses[i]);
            }
        }
    }

    function deleteAddresses(address[] memory addresses) public restricted {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            require(_addressList.remove(addresses[i]), "The address is not in list yet");
            emit DeleteAddress(addresses[i]);
        }
    }

    function tryDeleteAddresses(address[] memory addresses) public restricted {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            if (_addressList.remove(addresses[i])) {
                emit DeleteAddress(addresses[i]);
            }
        }
    }

    function version() public pure returns (uint256) {
        return 3;
    }
}
