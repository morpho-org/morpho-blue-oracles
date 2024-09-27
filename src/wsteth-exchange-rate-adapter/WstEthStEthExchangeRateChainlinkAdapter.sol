// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IStEth} from "./interfaces/IStEth.sol";
import {MinimalAggregatorV3Interface} from "./interfaces/MinimalAggregatorV3Interface.sol";

/// @title WstEthStEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/stETH exchange rate price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract WstEthStEthExchangeRateChainlinkAdapter is MinimalAggregatorV3Interface {
    /// @inheritdoc MinimalAggregatorV3Interface
    /// @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "wstETH/stETH exchange rate";

    /// @notice The address of stETH on Ethereum.
    IStEth public constant ST_ETH = IStEth(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    /// @inheritdoc MinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `getPooledEthByShares`'s return value is greater than `type(int256).max`.
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        // It is assumed that `getPooledEthByShares` returns a price with 18 decimals precision.
        return (0, int256(ST_ETH.getPooledEthByShares(1 ether)), 0, 0, 0);
    }
}
