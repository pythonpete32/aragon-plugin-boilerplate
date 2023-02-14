// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

contract BoilerplatePlugin is PluginUUPSUpgradeable {
    // 01 - Declare the permission ID
    bytes32 public constant DEMO_PERMISSION_ID = keccak256("DEMO_PERMISSION");



    // 02 - Disable the constructor
    constructor() {
        _disableInitializers();
    }

    // 03 - Declare the initialize function
    function initialize(IDAO _dao) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
    }

    
    // 04 - Create a function protected by the Permission Manager
    function protectedByDAO(address admin, bool isAdmin) external auth(DEMO_PERMISSION_ID) {
        // Add functionality he

    }


    // 05 - This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
