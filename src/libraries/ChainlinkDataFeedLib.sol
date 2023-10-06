// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

import {ErrorsLib} from "./ErrorsLib.sol";

/// @title ChainlinkDataFeedLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing functions to interact with a Chainlink-compliant feed.
library ChainlinkDataFeedLib {
    /// @dev Performs safety checks and returns the latest price of a `feed`.
    /// @dev When `feed` is the address zero, returns 1.
    function getPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 1;

        (, int256 answer,,,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);

        return uint256(answer);
    }

    /// @dev Returns the number of decimals of a `feed`.
    /// @dev When `feed` is the address zero, returns 0.
    function getDecimals(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 0;

        return feed.decimals();
    }
}
