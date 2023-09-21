// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract OracleThreeWay is IOracle {
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
                36 + baseTokenDecimals + _feedDecimals(quoteFeed) - _feedDecimals(firstBaseFeed)
                    - _feedDecimals(secondBaseFeed) - quoteTokenDecimals
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (_feedPrice(FIRST_BASE_FEED) * _feedPrice(FIRST_BASE_FEED) * SCALE_FACTOR) / _feedPrice(QUOTE_FEED);
    }

    /// @dev Performing some security checks and returns the latest price of a feed.
    /// @dev When feed is the address 0, returns 1.
    function _feedPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 1;
        (, int256 answer,,,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);
        return uint256(answer);
    }

    /// @dev Returns feed.decimals() if feed != address(0), else returns 0.

    function _feedDecimals(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 0;
        return feed.decimals();
    }
}
