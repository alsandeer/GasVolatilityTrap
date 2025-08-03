// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GasSignalEmitter — emits signal when trap is triggered
contract GasSignalEmitter {
    event GasAlert(bytes data);

    function emitSignal(bytes calldata data) external {
        emit GasAlert(data);
    }
}
