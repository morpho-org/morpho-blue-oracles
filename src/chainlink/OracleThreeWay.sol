// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, DataFeedLib} from "./libraries/DataFeedLib.sol";

contract OracleThreeWay is IOracle {
    using DataFeedLib for AggregatorV3Interface;

    /* CONSTANT */

    /// @notice First Base feed.
    AggregatorV3Interface public immutable FIRST_BASE_FEED;
    /// @notice Second Base feed.
    AggregatorV3Interface public immutable SECOND_BASE_FEED;
    /// @notice Quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED;
    /// @notice Price scale factor. Automatically computed at contract creation.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param firstBaseFeed First Base feed.
    /// @param secondBaseFeed Second Base feed.
    /// @param quoteFeed Quote feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals. Pass 0 if the price = 1.
    constructor(
        AggregatorV3Interface firstBaseFeed,
        AggregatorV3Interface secondBaseFeed,
        AggregatorV3Interface quoteFeed,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        FIRST_BASE_FEED = firstBaseFeed;
        SECOND_BASE_FEED = secondBaseFeed;
        QUOTE_FEED = quoteFeed;
        // SCALE_FACTOR = 10 ** (36 + (quoteFeedDecimals - quoteTokenDecimals) - (firstBaseFeedDecimals +
        // secondBaseFeedDecimals - baseTokenDecimals))
        SCALE_FACTOR = 10
            ** (
                36 + baseTokenDecimals + quoteFeed.wrapDecimals() - firstBaseFeed.wrapDecimals()
                    - secondBaseFeed.wrapDecimals() - quoteTokenDecimals
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (FIRST_BASE_FEED.wrapPrice() * SECOND_BASE_FEED.wrapPrice() * SCALE_FACTOR) / QUOTE_FEED.wrapPrice();
    }
}
