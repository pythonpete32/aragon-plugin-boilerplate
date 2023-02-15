// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {DAO} from "aragon-plugin-base/contracts/lib/dao-authorizable/DAO.sol";
import {PermissionLib} from "aragon-plugin-base/contracts/lib/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "aragon-plugin-base/contracts/lib/plugin/PluginSetup.sol";

import {TokenSalePlugin} from "./TokenSalePlugin.sol";

contract TokenSaleSetup is PluginSetup {
    address private pluginBase;

    constructor() {
        pluginBase = address(new TokenSalePlugin());
    }

    // 02 - Prepare installation
    function prepareInstallation(
        address _dao,
        bytes memory _data
    ) external returns (address plugin, PreparedDependency memory preparedDependency) {
        // 02.1 - Decode `_data` to extract the params needed for deploying and initializing the plugin,
        (address token, uint256 price, uint256 target, uint256 start, uint256 end) = abi.decode(
            _data,
            (address, uint256, uint256, uint256, uint256)
        );

        // 02.2 - encode the initialization data for the plugin
        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address,uint256,uint256,uint256,uint256)")),
            _dao,
            token,
            price,
            target,
            start,
            end
        );
        plugin = createERC1967Proxy(address(pluginBase), initData);

        // 02.30 - Prepare permissions on the plugin
        PermissionLib.MultiTargetPermission[]
            memory permissions = new PermissionLib.MultiTargetPermission[](2);

        // 02.31 - Grant the DAO the permission to pause tokensale
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            address(0),
            TokenSalePlugin(plugin).PAUSE_PERMISSION_ID()
        );

        // 02.32 - Grant the DAO the permission to finalise tokensale
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            address(0),
            TokenSalePlugin(plugin).FINALISE_PERMISSION_ID()
        );

        //  02.33 - Grant the Plugin the permission to execute actions on the DAO
        permissions[2] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            address(0),
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        // 02.40 - Return the plugin dependency
        preparedDependency.helpers = new address[](0);
        preparedDependency.permissions = permissions;
    }

    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        // 03.1 - Extract the plugin address
        address plugin = _payload.plugin;

        // 03.2 - Prepare permissions on the plugin
        permissions = new PermissionLib.MultiTargetPermission[](3);

        // 03.21 - Revoke the DAO the permission to pause tokensale
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            address(0),
            TokenSalePlugin(plugin).PAUSE_PERMISSION_ID()
        );

        // 03.22 - Revoke the DAO the permission to finalise tokensale
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            address(0),
            TokenSalePlugin(plugin).FINALISE_PERMISSION_ID()
        );

        //  03.23 - Grant the Plugin the permission to execute actions on the DAO
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            address(0),
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );
    }

    function getImplementationAddress() external view virtual override returns (address) {
        return pluginBase;
    }
}
