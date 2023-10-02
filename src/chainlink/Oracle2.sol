// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, DataFeedLib} from "./libraries/DataFeedLib.sol";

contract Oracle2 is IOracle {
    using DataFeedLib for AggregatorV3Interface;

    /* CONSTANT */

    /// @notice Base feed.
    AggregatorV3Interface public immutable BASE_FEED;
    /// @notice Quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED;
    /// @notice Price scale factor. Automatically computed at contract creation.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param baseFeed Base feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals. Pass 0 if the price = 1.
    /// @param quoteFeed Quote feed. Pass address zero if the price = 1.
    /// @param quoteTokenDecimals Quote token decimals. Pass 0 if the price = 1.
    constructor(
        AggregatorV3Interface baseFeed,
        uint256 baseTokenDecimals,
        AggregatorV3Interface quoteFeed,
        uint256 quoteTokenDecimals
    ) {
        BASE_FEED = baseFeed;
        QUOTE_FEED = quoteFeed;
        // SCALE_FACTOR = 10 ** (36 + (baseTokenDecimals - baseFeedDecimals) - (quoteTokenDecimals - quoteFeedDecimals))
        SCALE_FACTOR =
            10 ** (36 + baseTokenDecimals + quoteFeed.getDecimals() - baseFeed.getDecimals() - quoteTokenDecimals);
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (BASE_FEED.getPrice() * SCALE_FACTOR) / QUOTE_FEED.getPrice();
    }
}
