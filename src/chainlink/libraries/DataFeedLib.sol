// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ErrorsLib} from "./ErrorsLib.sol";
import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library DataFeedLib {
    /// @dev Performing some security checks and returns the lateste price of a feed.
    /// @dev When feed = address(0), returns 1.
    function wrapPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 1;
        (, int256 answer,,,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);
        return uint256(answer);
    }

    /// @dev Returns feed.decimals() if feed != address(0), else returns 0.
    function wrapDecimals(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 0;
        return feed.decimals();
    }
}