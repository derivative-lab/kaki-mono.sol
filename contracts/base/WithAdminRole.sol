// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract WithAdminRole is AccessControlUpgradeable {
    bytes32 public constant GAME_ADMIN = keccak256("GAME_ADMIN");
    bytes32 public constant GAME_CLIENT = keccak256("GAME_CLIENT");

    function __WithAdminRole_init() internal initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GAME_ADMIN, msg.sender);
    }

    modifier onlyNonContract() {
        require(tx.origin == msg.sender, "NCC");
        _;
    }

    // @deprecated Use tx.origin == msg.sender
    // function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.
    /**
 not safe , on contract create call
 */
    // uint256 size;
    // // solhint-disable-next-line no-inline-assembly
    // assembly {
    //     size := extcodesize(account)
    // }
    // return size > 0;
    // }

    modifier restricted() {
        require(hasRole(GAME_ADMIN, msg.sender), "NGA");
        _;
    }

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "NADM");
        _;
    }

    function setupAdmin(address to) public restricted {
        grantRole(GAME_ADMIN, to);
    }

    function revokeAdmin(address to) public restricted {
        revokeRole(GAME_ADMIN, to);
    }
}
