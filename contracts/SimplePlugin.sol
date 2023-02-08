// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

/// @title SimplePlugin
/// @notice Enables Admins to transfer ETH from the DAO to a recipient without a vote.
contract SimplePlugin is PluginUUPSUpgradeable {

    bytes32 public constant DEMO_PERMISSION_ID = keccak256("DEMO_PERMISSION");
    uint256 public nonce;
    mapping(address => bool) public admins;

    constructor() {
        _disableInitializers();
    }

    function initialize(IDAO _dao, address admin) external initializer {
        __PluginUUPSUpgradeable_init(_dao);

        nonce = 0;
        admins[admin] = true;
    }

    function protectedByDAO(address admin, bool isAdmin) external auth(DEMO_PERMISSION_ID) {
        admins[admin] = isAdmin;
    }


    function protectedByPlugin(address _to, uint256 _amount) external {
        // validate params
        require(admins[msg.sender] = true, "NOT PERMITTED");

        // Create an action to transfer ETH from the DAO to the recipient.
        IDAO.Action[] memory action = new IDAO.Action[](1);
        action[0].to = _to;
        action[0].value = _amount;
        // no need to send data since we are not calling a function

        // plugin needs execute permission on DAO
        dao.execute(bytes32(nonce++), action, 0);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
