// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Core} from "modular-contracts/src/Core.sol";

interface BeforeIncrementCallback {
    function beforeIncrement(uint256 count) external returns (uint256);
}

contract CounterCore is Core {
    uint256 public count;

    function getSupportedCallbackFunctions()
        public
        pure
        override
        returns (SupportedCallbackFunction[] memory supportedCallbackFunctions)
    {
        supportedCallbackFunctions = new SupportedCallbackFunction[](1);
        supportedCallbackFunctions[0] = SupportedCallbackFunction({
            selector: BeforeIncrementCallback.beforeIncrement.selector,
            mode: CallbackMode.REQUIRED
        });
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == 0x00000001 || super.supportsInterface(interfaceId);
    }

    function increment() public {
        uint256 newCount = _beforeIncrement(count);
        count = newCount;
    }

    function _beforeIncrement(
        uint256 count
    ) internal returns (uint256 newCount) {
        (, bytes memory returndata) = _executeCallbackFunction(
            BeforeIncrementCallback.beforeIncrement.selector,
            abi.encodeCall(BeforeIncrementCallback.beforeIncrement, (count))
        );

        newCount = abi.decode(returndata, (uint256));
    }
}
