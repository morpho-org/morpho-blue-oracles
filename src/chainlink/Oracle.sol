// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract Oracle is IOracle {
    /* CONSTANT */

    /// @notice Base feed.
    AggregatorV3Interface public immutable BASE_FEED;
    /// @notice Quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED;
    /// @notice Maximum time since last update. The oracle will reverts when exceeded.
    uint256 public immutable STALE_TIMEOUT;
    /// @notice Price scale factor. Automatically computer at contract creation.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param baseFeed Base feed. Pass address zero for price = 1.
    /// @param baseTokenDecimals Base token decimals. Pass 0 if the price is one.
    /// @param quoteFeed Quote feed. Pass address zero for price = 1.
    /// @param quoteTokenDecimals Quote token decimals. Pass 0 if the price is one.
    /// @param staleTimeout Maximum time since last update. The oracle will reverts when exceeded.
    constructor(
        AggregatorV3Interface baseFeed,
        uint256 baseTokenDecimals,
        AggregatorV3Interface quoteFeed,
        uint256 quoteTokenDecimals,
        uint256 staleTimeout
    ) {
        BASE_FEED = baseFeed;
        QUOTE_FEED = quoteFeed;
        // SCALE_FACTOR = 10 ** (36 + (baseTokenDecimals - baseFeedDecimals) - (quoteTokenDecimals - quoteFeedDecimals))
        SCALE_FACTOR =
            10 ** (36 + baseTokenDecimals + _feedDecimals(quoteFeed) - _feedDecimals(baseFeed) - quoteTokenDecimals);
        STALE_TIMEOUT = staleTimeout;
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return _feedPrice(BASE_FEED) * SCALE_FACTOR / _feedPrice(QUOTE_FEED);
    }

    /// @dev Performing some security checks and returns the lateste price of a feed.
    /// @dev When feed = address(0), returns 1.
    function _feedPrice(AggregatorV3Interface feed) private view returns (uint256) {
        if (address(feed) == address(0)) return 1;
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);
        require(block.timestamp - updatedAt <= STALE_TIMEOUT, ErrorsLib.STALE_PRICE);
        return uint256(answer);
    }

    /// @dev Returns feed.decimals() if feed != address(0), else returns 0.
    function _feedDecimals(AggregatorV3Interface feed) private view returns (uint256) {
        if (address(feed) == address(0)) return 0;
        return feed.decimals();
    }
}
