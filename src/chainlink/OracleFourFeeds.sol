// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, DataFeedLib} from "./libraries/DataFeedLib.sol";

/// @title OracleFourFeeds
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Morpho Blue oracle using 4 Chainlink-compliant feeds.
contract OracleFourFeeds is IOracle {
    using DataFeedLib for AggregatorV3Interface;

    /* IMMUTABLES */

    /// @notice First base feed.
    AggregatorV3Interface public immutable FIRST_BASE_FEED;
    /// @notice Second base feed.
    AggregatorV3Interface public immutable SECOND_BASE_FEED;
    /// @notice First quote feed.
    AggregatorV3Interface public immutable FIRST_QUOTE_FEED;
    /// @notice Second quote feed.
    AggregatorV3Interface public immutable SECOND_QUOTE_FEED;
    /// @notice Price scale factor.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param firstBaseFeed First base feed. Pass address zero if the price = 1.
    /// @param secondBaseFeed Second base feed. Pass address zero if the price = 1.
    /// @param firstQuoteFeed Quote feed. Pass address zero if the price = 1.
    /// @param secondQuoteFeed Quote feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        AggregatorV3Interface firstBaseFeed,
        AggregatorV3Interface secondBaseFeed,
        AggregatorV3Interface firstQuoteFeed,
        AggregatorV3Interface secondQuoteFeed,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        FIRST_BASE_FEED = firstBaseFeed;
        SECOND_BASE_FEED = secondBaseFeed;
        FIRST_QUOTE_FEED = firstQuoteFeed;
        SECOND_QUOTE_FEED = secondQuoteFeed;
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + firstQuoteFeed.getDecimals() + secondQuoteFeed.getDecimals()
                    - firstBaseFeed.getDecimals() - secondBaseFeed.getDecimals() - baseTokenDecimals
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (FIRST_BASE_FEED.getPrice() * SECOND_BASE_FEED.getPrice() * SCALE_FACTOR)
            / (FIRST_QUOTE_FEED.getPrice() * SECOND_QUOTE_FEED.getPrice());
    }
}
