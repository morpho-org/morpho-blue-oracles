// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, DataFeedLib} from "./libraries/DataFeedLib.sol";

contract OracleFourFeeds is IOracle {
    using DataFeedLib for AggregatorV3Interface;

    /* CONSTANT */

    /// @notice First base feed.
    AggregatorV3Interface public immutable BASE_FEED_1;
    /// @notice Second base feed.
    AggregatorV3Interface public immutable BASE_FEED_2;
    /// @notice First quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED_1;
    /// @notice Second quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED_2;
    /// @notice Price scale factor, computed at contract creation.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param baseFeed1 First base feed. Pass address zero if the price = 1.
    /// @param baseFeed2 Second base feed. Pass address zero if the price = 1.
    /// @param quoteFeed1 First quote feed. Pass address zero if the price = 1.
    /// @param quoteFeed2 Second quote feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + quoteFeed1.getDecimals() + quoteFeed2.getDecimals() - baseFeed1.getDecimals()
                    - baseFeed2.getDecimals() - baseTokenDecimals
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (BASE_FEED_1.getPrice() * BASE_FEED_2.getPrice() * SCALE_FACTOR)
            / (QUOTE_FEED_1.getPrice() * QUOTE_FEED_2.getPrice());
    }
}
