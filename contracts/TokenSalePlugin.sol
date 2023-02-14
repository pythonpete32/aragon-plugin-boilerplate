// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

contract TokenSalePlugin is PluginUUPSUpgradeable {
    // ------------------------------------------------------------------------------ //
    //                               State Variables                                  //
    // ------------------------------------------------------------------------------ //

    // 01 - Declare the permission IDs
    bytes32 public constant PAUSE_PERMISSION_ID = keccak256("PAUSE_PERMISSION");
    bytes32 public constant FINALISE_PERMISSION_ID = keccak256("FINALISE_PERMISSION");

    // 02 - Declare the token sale variables
    IERC20 public token;
    uint256 public price;
    uint256 public target;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public totalRaised;
    bool public isPaused;
    bool public isFinalised;

    constructor() {
        _disableInitializers();
    }

    // 03 - Declare the initialize function
    function initialize(
        IDAO _dao,
        IERC20 _token,
        uint256 _price,
        uint256 _target,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
        token = _token;
        price = _price;
        target = _target;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        totalRaised = 0;
        isPaused = false;
        isFinalised = false;
    }

    // 05 - This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
