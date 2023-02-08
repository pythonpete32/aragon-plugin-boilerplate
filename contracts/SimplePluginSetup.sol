// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {DAO} from "aragon-plugin-base/contracts/lib/dao-authorizable/DAO.sol";
import {PermissionLib} from "aragon-plugin-base/contracts/lib/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "aragon-plugin-base/contracts/lib/plugin/PluginSetup.sol";

import {SimplePlugin} from "./SimplePlugin.sol";

/// @title SimplePluginSetup
/// @notice The setup contract of the `SimplePlugin` plugin.
contract SimplePluginSetup is PluginSetup {
    using Address for address;
    using Clones for address;
    using ERC165Checker for address;

    /// @notice The address zero to be used as oracle address for permissions.
    address private constant NO_ORACLE = address(0);

    address private adminTransferBase;

    /// @notice The contract constructor, that deployes the bases.
    constructor() {
        adminTransferBase = address(new SimplePlugin());
    }

    /// @inheritdoc IPluginSetup
    function prepareInstallation(
        address _dao,
        bytes memory _data
    ) external returns (address plugin, PreparedDependency memory preparedDependency) {
        // Decode `_data` to extract the params needed for deploying and initializing `AdminTransfer` plugin,
        address admin = abi.decode(_data, (address));

        // encode the initialization data for the plugin
        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address)")),
            _dao,
            admin
        );

        // deploy the plugin
        plugin = createERC1967Proxy(address(adminTransferBase), initData);

        // Prepare permissions
        PermissionLib.MultiTargetPermission[]
            memory permissions = new PermissionLib.MultiTargetPermission[](2);

        // Set plugin permissions to be granted.
        // Grant the list of permissions of the plugin to the DAO.
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            NO_ORACLE,
            // AdminTransferPlugin.CONFIGURE_PERMISSION_ID()
            keccak256("DEMO_PERMISSION")
        );

        // Grant `EXECUTE_PERMISSION` of the DAO to the plugin.
        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            NO_ORACLE,
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        // helpers not used but required in the return
        address[] memory helpers = new address[](0);

        preparedDependency.helpers = helpers;
        preparedDependency.permissions = permissions;
    }

    /// @inheritdoc IPluginSetup
    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        // Prepare permissions
        require(_payload.currentHelpers.length == 0, "No helpers should be passed");

        permissions = new PermissionLib.MultiTargetPermission[](2);

        // Set permissions to be Revoked.
        // Revoke the list of prmissions of the plugin to the DAO.
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            NO_ORACLE,
            keccak256("DEMO_PERMISSION")
        );

        // Revoke `EXECUTE_PERMISSION` of the DAO to the plugin.
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
        return adminTransferBase;
    }
}
