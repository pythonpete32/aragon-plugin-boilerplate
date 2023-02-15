// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

contract BoilerplatePlugin is PluginUUPSUpgradeable {
    bytes32 public constant DEMO_PERMISSION_ID = keccak256("DEMO_PERMISSION");

    constructor() {
        _disableInitializers();
    }

    function initialize(IDAO _dao) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
    }

    function protectedByDAO(address admin, bool isAdmin) external auth(DEMO_PERMISSION_ID) {
        // Add functionality here
    }

    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
