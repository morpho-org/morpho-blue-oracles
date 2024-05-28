// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ISfrxEth} from "./interfaces/ISfrxEth.sol";
import {MinimalAggregatorV3Interface} from "../wsteth-exchange-rate-adapter/interfaces/MinimalAggregatorV3Interface.sol";

/// @title SfrxEthFrxEthExchangeRateChainlinkAdapter
/// @notice sfrxETH/frxETH exchange rate price feed
/// @dev The contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract SfrxEthFrxEthExchangeRateChainlinkAdapter is
    MinimalAggregatorV3Interface
{
    /// @notice inheritdoc MinimalAggregatorV3Interface
    /// @dev The calculated price has 18 decimals precision.
    uint8 public constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "sfrxETH/frxETH exchange rate";

    /// @notice The address of sfrxETH on Ethereum.
    ISfrxEth public constant SFRX_ETH =
        ISfrxEth(0xac3E018457B222d93114458476f3E3416Abbe38F);

    /// @inheritdoc MinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `pricePerShare`'s return value is greater than `type(int256).max`.
    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        // It is assumed that `pricePerShare` returns a price with 18 decimals precision.
        return (0, int256(SFRX_ETH.pricePerShare()), 0, 0, 0);
    }
}
