// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {DAO} from "aragon-plugin-base/contracts/lib/dao-authorizable/DAO.sol";
import {PermissionLib} from "aragon-plugin-base/contracts/lib/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "aragon-plugin-base/contracts/lib/plugin/PluginSetup.sol";

import {BurnPlugin} from "./BurnPlugin.sol";

contract BurnPluginSetup is PluginSetup {
    address private pluginBase;

    constructor() {
        pluginBase = address(new BurnPlugin());
    }

    function prepareInstallation(
        address _dao,
        bytes memory _data
    ) external returns (address plugin, PreparedDependency memory preparedDependency) {
        // 1. decode _data to extract the params needed for deploying and initializing the plugin,
        address token = abi.decode(_data, (address));

        // 2. encode the initialization data for the plugin
        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address)")),
            _dao,
            token
        );

        // 3. create the plugin
        plugin = createERC1967Proxy(address(pluginBase), initData);

        // 4. prepare permissions on the plugin
        PermissionLib.MultiTargetPermission[]
            memory permissions = new PermissionLib.MultiTargetPermission[](2);

        // 5. grant the DAO the permission to burn tokens
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            address(0), // NO_ORACLE
            BurnPlugin(plugin).BURN_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            address(0), // NO_ORACLE
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        // 6. return the permissions
        preparedDependency = PreparedDependency(new address[](0), permissions);
    }

    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        // 1. prepare permissions on the plugin
        permissions = new PermissionLib.MultiTargetPermission[](2);

        address plugin = _payload.plugin;

        // 2. Revoking the DAO the permission to burn tokens
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            plugin,
            _dao,
            address(0), // NO_ORACLE
            BurnPlugin(plugin).BURN_PERMISSION_ID()
        );

        // 3. Revoking the DAO the permission to execute actions on the plugin
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _dao,
            plugin,
            address(0), // NO_ORACLE
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );
    }

    function getImplementationAddress() external view virtual override returns (address) {
        return pluginBase;
    }
}
