// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

import {ErrorsLib} from "./ErrorsLib.sol";

struct Quantity {
    uint256 amount;
    uint256 decimals;
}

/// @title ChainlinkDataFeedAltLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing functions to interact with a Chainlink-compliant feed.
library ChainlinkDataFeedAltLib {
    /// @notice Assuming `feed` is pricing output wrt to input, this converts an input amount into an output amount.
    function convert(AggregatorV3Interface feed, Quantity memory inputQuantity, uint256 outputDecimals)
        internal
        view
        returns (Quantity memory outputQuantity)
    {
        if (address(feed) == address(0)) return inputQuantity;

        (, int256 answer,,,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);

        outputQuantity.decimals = outputDecimals;
        outputQuantity.amount = (inputQuantity.amount * 10 ** (outputDecimals + feed.decimals()))
            / (10 ** inputQuantity.decimals * uint256(answer));
    }
}
