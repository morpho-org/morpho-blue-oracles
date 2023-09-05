// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Oracle {
    uint256 public constant DESIRED_PRECISION = 36;
    AggregatorV3Interface public immutable FEED;
    uint256 public immutable TOKEN_DECIMALS;
    uint256 public immutable FEED_PRECISION;

    constructor(AggregatorV3Interface feed, uint256 tokenDecimals) {
        FEED = feed;
        TOKEN_DECIMALS = tokenDecimals;
        FEED_PRECISION = FEED.decimals();
    }

    function price() external view returns (uint256) {
        (, int256 answer,,,) = FEED.latestRoundData();
        return uint256(answer) * 10**(TOKEN_DECIMALS + DESIRED_PRECISION - FEED_PRECISION);
    }
}
