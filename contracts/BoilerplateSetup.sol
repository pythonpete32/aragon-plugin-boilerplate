// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {DAO} from "aragon-plugin-base/contracts/lib/dao-authorizable/DAO.sol";
import {PermissionLib} from "aragon-plugin-base/contracts/lib/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "aragon-plugin-base/contracts/lib/plugin/PluginSetup.sol";

import {BoilerplatePlugin} from "./BoilerplatePlugin.sol";

contract BoilerplateSetup is PluginSetup {
    address private pluginBase;

    constructor() {
        pluginBase = address(new BoilerplatePlugin());
    }

    function prepareInstallation(
        address _dao,
        bytes memory _data
    ) external returns (address plugin, PreparedDependency memory preparedDependency) {}

    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {}

    function getImplementationAddress() external view virtual override returns (address) {}
}
