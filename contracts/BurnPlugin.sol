// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

interface IERC20Burnable {
    function burn(address account, uint256 amount) external;
}


contract BurnPlugin is PluginUUPSUpgradeable {
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");
    IERC20Burnable public token;



    constructor() {
        _disableInitializers();
    }

    function initialize(IDAO _dao, IERC20Burnable _token) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
        token = _token;
    }

    function BurnToken(address _burnUser, uint256 _amount) external auth(BURN_PERMISSION_ID) {
        // Add functionality here   

        IDAO.Action[] memory action = new IDAO.Action[](1);
        action[0].to = token;
        action[0].value = 0;
        action[0].data = abi.encodeWithSelector(IERC20Burnable.burn.selector, _burnUser, _amount);

        dao.execute(bytes32(nonce++), action, 0);


    }


    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[48] private __gap;
}
