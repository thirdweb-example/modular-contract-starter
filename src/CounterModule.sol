// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Module} from "modular-contracts/src/Module.sol";
import {Role} from "modular-contracts/src/Role.sol";

library CounterStorage {
    /// @custom:storage-location erc7201:token.minting.counter
    bytes32 public constant COUNTER_STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256("counter")) - 1)) &
            ~bytes32(uint256(0xff));

    struct Data {
        uint256 step;
    }

    function data() internal pure returns (Data storage data_) {
        bytes32 position = COUNTER_STORAGE_POSITION;
        assembly {
            data_.slot := position
        }
    }
}

contract counterModule is Module {
    /*//////////////////////////////////////////////////////////////
                            Module Config
    //////////////////////////////////////////////////////////////*/

    function getModuleConfig()
        public
        pure
        override
        returns (ModuleConfig memory config)
    {
        config.callbackFunctions = new CallbackFunction[](1);
        config.fallbackFunctions = new FallbackFunction[](2);

        config.callbackFunctions[0] = CallbackFunction(
            this.beforeIncrement.selector
        );
        config.fallbackFunctions[0] = FallbackFunction({
            selector: this.getStep.selector,
            permissionBits: 0
        });
        config.fallbackFunctions[0] = FallbackFunction({
            selector: this.setStep.selector,
            permissionBits: Role._MANAGER_ROLE
        });

        config.requiredInterfaces = new bytes4[](1);
        config.requiredInterfaces[0] = 0x00000001;

        config.registerInstallationCallback = true;
    }

    /*//////////////////////////////////////////////////////////////
                          Install / Uninstall
    //////////////////////////////////////////////////////////////*/

    function onInstall(bytes calldata data) external {
        uint256 step = abi.decode(data, (uint256));
        _counterStorage().step = step;
    }

    function onUninstall(bytes calldata data) external {}

    function encodeBytesOnInstall(
        uint256 step
    ) external pure returns (bytes memory) {
        return abi.encode(step);
    }

    function encodeBytesOnUninstall() external pure returns (bytes memory) {
        return "";
    }

    /*//////////////////////////////////////////////////////////////
                       Callback & Fallback Functions
    //////////////////////////////////////////////////////////////*/

    function beforeIncrement(uint256 count) external view returns (uint256) {
        return count + _counterStorage().step;
    }

    function getStep() external view returns (uint256) {
        return _counterStorage().step;
    }

    function setStep(uint256 step) external {
        _counterStorage().step = step;
    }

    /*//////////////////////////////////////////////////////////////
                           Internal Functions
    //////////////////////////////////////////////////////////////*/

    function _counterStorage()
        internal
        pure
        returns (CounterStorage.Data storage)
    {
        return CounterStorage.data();
    }
}
