// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {DAO} from "aragon-plugin-base/contracts/lib/dao-authorizable/DAO.sol";
import {PermissionLib} from "aragon-plugin-base/contracts/lib/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "aragon-plugin-base/contracts/lib/plugin/PluginSetup.sol";

import {BoilerplatePlugin} from "./BoilerplatePlugin.sol";

contract SimplePluginSetup is PluginSetup {
    address private pluginBase;
    address private constant NO_ORACLE = address(0);

    constructor() {
        pluginBase = address(new BoilerplatePlugin());
    }

    /// @inheritdoc IPluginSetup
    function prepareInstallation(
        address _dao,
        bytes memory _data
    ) external returns (address plugin, PreparedDependency memory preparedDependency) {
        // 1. Decode `_data` to extract the params needed for deploying and initializing plugin,
        address admin = abi.decode(_data, (address));

        // 2. encode the initialization data for the plugin
        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address)")),
            _dao,
            admin
        );

        // 3. deploy the plugin
        plugin = createERC1967Proxy(address(pluginBase), initData);

        // 4. Prepare permissions
        PermissionLib.MultiTargetPermission[]
            memory permissions = new PermissionLib.MultiTargetPermission[](2);

        // 5. Grant the DAO DEMO_PERMISSION_ID
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            NO_ORACLE,
            BoilerplatePlugin(plugin).DEMO_PERMISSION_ID()
        );

        // 6. Grant `EXECUTE_PERMISSION` of the DAO to the plugin.
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            NO_ORACLE,
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        // 7. helpers not used but required in the return
        preparedDependency.helpers = new address[](0);
        preparedDependency.permissions = permissions;
    }

    /// @inheritdoc IPluginSetup
    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        // 1. Prepare permissions
        permissions = new PermissionLib.MultiTargetPermission[](2);

        // 2. Revoke the DAO DEMO_PERMISSION_ID
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            NO_ORACLE,
            BoilerplatePlugin(_payload.plugin).DEMO_PERMISSION_ID()
        );

        // 3. Revoke `EXECUTE_PERMISSION` of the DAO to the plugin.
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _dao,
            _payload.plugin,
            NO_ORACLE,
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );
    }

    /// @inheritdoc IPluginSetup
    function getImplementationAddress() external view virtual override returns (address) {
        return pluginBase;
    }
}
