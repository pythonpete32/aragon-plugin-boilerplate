// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

/// @title AdminTransferPlugin
/// @notice Enables Admins to transfer ANT Tokens from the DAO to a recipient without a vote.
contract AdminTransferPlugin is PluginUUPSUpgradeable {
    /* ====================================================================== */
    /*                              PERMISSION IDS
    /* ====================================================================== */
    bytes32 public constant CONFIGURE_PERMISSION_ID =
        keccak256("ADMIN_TRANSFER_CONFIGURATION_PERMISSION");

    /* ====================================================================== */
    /*                              STATE
    /* ====================================================================== */

    /// @notice The nonce used for the next action.
    uint256 public nonce;

    /// @notice The ANT token.
    IERC20 public ANT;

    /// @notice The maximum amount of ANT that can be transferred in a single action.
    uint256 public MAX_TRANSFER_AMOUNT;

    /// @notice The address of the admins who can transfer ANT.
    mapping(address => bool) public admins;

    /* ====================================================================== */
    /*                              FUNCTIONS
    /* ====================================================================== */

    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20 _ant, IDAO _dao, address[] memory _admins) external initializer {
        __PluginUUPSUpgradeable_init(_dao);

        ANT = _ant;
        MAX_TRANSFER_AMOUNT = 69 * 10 ** 18;
        nonce = 0;

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    function updateAdmins(address admin, bool isAdmin) external auth(CONFIGURE_PERMISSION_ID) {
        admins[admin] = isAdmin;
    }

    function sendANT(address _recipient, uint256 _amount) external {
        // validate params
        require(admins[msg.sender] = true, "Not_Admin");
        require(_amount <= MAX_TRANSFER_AMOUNT, "Too_Much_ANT");
        require(ANT.balanceOf(address(dao)) >= _amount, "Not_Enough_ANT_In_DAO");

        // Create an action to transfer ANT from the DAO to the recipient.
        IDAO.Action[] memory action = new IDAO.Action[](1);
        action[0].to = address(ANT);
        action[0].value = 0;
        action[0].data = abi.encodeWithSelector(ANT.transfer.selector, _recipient, _amount);

        dao.execute(bytes32(nonce++), action, 0);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
