// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

/// @title GasVolatilityTrap — triggers when basefee changes > 2% between blocks
contract GasVolatilityTrap is ITrap {
    uint256 public constant THRESHOLD_PERCENT = 2;

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes("Not enough data"));

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        if (previous == 0) return (false, bytes("Previous basefee is zero"));

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percentChange = (diff * 100) / previous;

        if (percentChange >= THRESHOLD_PERCENT) {
            return (true, abi.encode("Gas volatility detected"));
        }

        return (false, bytes("Stable gas"));
    }
}
