// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract GasVolatilityTrap is ITrap {
    uint256 private constant DEFAULT_THRESHOLD_PERCENT = 2;

    struct CollectOutput {
        uint256 basefee;
        uint256 threshold;
    }

    function collect() external view override returns (bytes memory) {
        CollectOutput memory output = CollectOutput({
            basefee: block.basefee,
            threshold: DEFAULT_THRESHOLD_PERCENT
        });

        return abi.encode(output);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes("Not enough data"));

        CollectOutput memory current = abi.decode(data[0], (CollectOutput));
        CollectOutput memory previous = abi.decode(data[1], (CollectOutput));

        if (previous.basefee == 0) return (false, bytes("Previous basefee is zero"));

        uint256 diff = current.basefee > previous.basefee
            ? current.basefee - previous.basefee
            : previous.basefee - current.basefee;

        uint256 percentChange = (diff * 100) / previous.basefee;

        if (percentChange >= previous.threshold) {
            return (
                true,
                abi.encode(
                    "Gas volatility detected",
                    current.basefee,
                    previous.basefee,
                    percentChange
                )
            );
        }

        return (false, bytes("Stable gas"));
    }
}
