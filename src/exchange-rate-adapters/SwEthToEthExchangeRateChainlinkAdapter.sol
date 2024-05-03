// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {ISwETH} from "../interfaces/swell/ISwETH.sol";
import {IMinimalAggregatorV3Interface} from "../interfaces/IMinimalAggregatorV3Interface.sol";

/// @title SwEthToEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice swETH/ETH exchange rate price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract SwEthToEthExchangeRateChainlinkAdapter is IMinimalAggregatorV3Interface {
    /// @inheritdoc IMinimalAggregatorV3Interface
    // @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public override constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "swETH/ETH exchange rate";

    /// @notice The address of the Swell Network swETH contract in Ethereum.
    ISwETH public constant SWETH = ISwETH(0xf951E335afb289353dc249e82926178EaC7DEd78);

    /// @inheritdoc IMinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `swETHToETHRate`'s return value is greater than `type(int256).max`.
    function latestRoundData() external override view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, int256(SWETH.swETHToETHRate()), 0, 0, 0);
    }
}
