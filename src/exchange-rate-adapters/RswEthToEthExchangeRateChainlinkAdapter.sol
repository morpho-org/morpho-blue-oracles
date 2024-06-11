// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IRswETH} from "../interfaces/swell/IRswETH.sol";
import {IMinimalAggregatorV3Interface} from "../interfaces/IMinimalAggregatorV3Interface.sol";

/// @title RswEthToEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice rswETH/ETH exchange rate price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract RswEthToEthExchangeRateChainlinkAdapter is IMinimalAggregatorV3Interface {
    /// @inheritdoc IMinimalAggregatorV3Interface
    // @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public constant override decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "rswETH/ETH exchange rate";

    /// @notice The address of the Swell Network rswETH contract in Ethereum.
    IRswETH public constant RSWETH = IRswETH(0xFAe103DC9cf190eD75350761e95403b7b8aFa6c0);

    /// @inheritdoc IMinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `rswETHToETHRate`'s return value is greater than `type(int256).max`.
    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, int256(RSWETH.rswETHToETHRate()), 0, 0, 0);
    }
}
