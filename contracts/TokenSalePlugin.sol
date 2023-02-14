// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IDAO} from "aragon-plugin-base/contracts/lib/interfaces/IDAO.sol";
import {PluginUUPSUpgradeable} from "aragon-plugin-base/contracts/lib/plugin/PluginUUPSUpgradeable.sol";

contract TokenSalePlugin is PluginUUPSUpgradeable {
    // ------------------------------------------------------------------------------ //
    //                               State Variables                                  //
    // ------------------------------------------------------------------------------ //

    // 01 - Declare constants
    bytes32 public constant PAUSE_PERMISSION_ID = keccak256("PAUSE_PERMISSION");
    bytes32 public constant FINALISE_PERMISSION_ID = keccak256("FINALISE_PERMISSION");
    address public constant ETH = address(0);

    // 02 - Declare the token sale variables
    address public token;
    uint256 public price;
    uint256 public target;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalRaised;
    bool public isPaused;
    bool public isFinalised;

    // 03 - Declare the events
    event Contributed(address indexed contributor, uint256 amount);
    event Finalised();
    event Paused(bool isPaused);

    constructor() {
        _disableInitializers();
    }

    // 04 - Declare the initialize function
    function initialize(
        IDAO _dao,
        address _token,
        uint256 _price,
        uint256 _target,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
        token = _token;
        price = _price;
        target = _target;
        startTime = _startTimestamp;
        endTime = _endTimestamp;
        totalRaised = 0;
        isPaused = false;
        isFinalised = false;
    }

    // ------------------------------------------------------------------------------ //
    //                               FUNCTIONS                                        //
    // ------------------------------------------------------------------------------ //

    // 05 - protected by the Permission Manager
    function setPaused(bool _isPaused) external auth(PAUSE_PERMISSION_ID) {
        // 05.1 - Check the preconditions
        require(!isFinalised, "sale is finalised");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "sale is not active");

        // 05.2 - Update the state
        isPaused = _isPaused;
        emit Paused(_isPaused);
    }

    // 06 - protected by the Permission Manager
    function finalise() external auth(FINALISE_PERMISSION_ID) {
        // 06.1 - Check the preconditions
        require(!isFinalised, "sale is finalised");

        // 06.2 - Update the state
        isFinalised = true;
        emit Finalised();
    }

    // 07 - Entry point for the token sale
    function contribute(uint256 amount) external payable {
        // 07.1 - Check the preconditions
        require(!isFinalised, "sale is finalised");
        require(!isPaused, "sale is paused");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "sale is not active");
        require(totalRaised + amount <= target, "sale target reached");
        require(msg.value >= amount, "insufficient funds");

        // 07.2 - Deposit the funds into the DAO and transfer the tokens to the contributor
        string memory ref = string(abi.encodePacked("TOKEN SALE:", amount, msg.sender));
        dao.deposit{value: msg.value}(ETH, msg.value, ref);
        _transferTokens(msg.sender, amount * price);

        // 07.3 - Update the total raised
        totalRaised += amount;

        // 07.4 - Emit the event
        emit Contributed(msg.sender, amount);
    }

    // 08 - Transfer tokens from the DAO to the contributor
    function _transferTokens(address _recipient, uint256 _amount) internal {
        // 08.1 - Create the action,
        IDAO.Action[] memory action = new IDAO.Action[](1);
        action[0].to = token;
        action[0].value = _amount;
        action[0].data = abi.encodeWithSignature("transfer(address,uint256)", _recipient, _amount);

        // 08.2 - Execute the action
        // NOTE: the plugin must have the EXECUTE_PERMISSION on the DAO
        dao.execute(bytes32(block.timestamp), action, 0);
    }

    uint256[48] private __gap;
}
