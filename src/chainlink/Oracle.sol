// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract Oracle is IOracle {
    /* CONSTANT */

    AggregatorV3Interface public immutable BASE_FEED;
    AggregatorV3Interface public immutable QUOTE_FEED;
    uint256 public immutable STALE_TIMEOUT;
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

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

    function price() external view returns (uint256) {
        return _feedPrice(BASE_FEED) * SCALE_FACTOR / _feedPrice(QUOTE_FEED);
    }

    function _feedPrice(AggregatorV3Interface feed) private view returns (uint256) {
        if (address(feed) == address(0)) return 1;
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);
        require(block.timestamp - updatedAt <= STALE_TIMEOUT, ErrorsLib.STALE_PRICE);
        return uint256(answer);
    }

    function _feedDecimals(AggregatorV3Interface feed) private view returns (uint256) {
        if (address(feed) == address(0)) return 0;
        return feed.decimals();
    }
}
