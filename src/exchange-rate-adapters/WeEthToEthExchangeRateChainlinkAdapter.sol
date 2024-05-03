// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IWeEth} from "../interfaces/etherfi/IWeEth.sol";
import {IMinimalAggregatorV3Interface} from "../interfaces/IMinimalAggregatorV3Interface.sol";

/// @title WeEthToEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice weETH/ETH exchange rate price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract WeEthToEthExchangeRateChainlinkAdapter is IMinimalAggregatorV3Interface {
    /// @inheritdoc IMinimalAggregatorV3Interface
    // @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public override constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "weETH/ETH exchange rate";

    /// @notice The address of the weETH token on Ethereum.
    IWeEth public constant WEETH = IWeEth(0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee);

    /// @inheritdoc IMinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `getRate()`'s return value is greater than `type(int256).max`.
    function latestRoundData() external override view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, int256(WEETH.getRate()), 0, 0, 0);
    }
}
