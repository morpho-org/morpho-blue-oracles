// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, ChainlinkDataFeedLib} from "./libraries/ChainlinkDataFeedLib.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";

/// @title ChainlinkOracle
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Morpho Blue oracle using Chainlink-compliant feeds.
contract ChainlinkOracle is IOracle {
    using VaultLib for IERC4626;
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    /* IMMUTABLES */

    /// @notice Vault.
    IERC4626 public immutable VAULT;
    /// @notice Conversion sample decimals. The decimals of the shares sample used to convert to the underlying asset.
    /// @notice Should be chosen such that converting `10 ** CONVERSION_SAMPLE_DECIMALS` to assets has enough precision.
    uint256 public immutable CONVERSION_SAMPLE_DECIMALS;
    /// @notice Conversion sample, equals to 10 ** CONVERSION_SAMPLE_DECIMALS.
    uint256 public immutable CONVERSION_SAMPLE;
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

    /// @param vault Vault. Pass address zero to omit this parameter.
    /// @param baseFeed1 First base feed. Pass address zero if the price = 1.
    /// @param baseFeed2 Second base feed. Pass address zero if the price = 1.
    /// @param quoteFeed1 First quote feed. Pass address zero if the price = 1.
    /// @param quoteFeed2 Second quote feed. Pass address zero if the price = 1.
    /// @param conversionSampleDecimals Conversion sample decimals. Pass 0 if the oracle does not use a vault.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        IERC4626 vault,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 conversionSampleDecimals,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        // The vault parameter is used for ERC4626 tokens, to price its shares.
        // It is used to price `10 ** CONVERSION_SAMPLE_DECIMALS` of the vault shares, so it requires dividing
        // by that number, hence the `CONVERSION_SAMPLE_DECIMALS` subtraction in the `SCALE_FACTOR` definition.
        VAULT = vault;
        CONVERSION_SAMPLE_DECIMALS = conversionSampleDecimals;
        CONVERSION_SAMPLE = 10 ** CONVERSION_SAMPLE_DECIMALS;
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;
        // Let pB1 and pB2 be the base prices, and pQ1 and pQ2 the quote prices (price of 1e(decimals) asset), in a
        // common quote currency.
        // Chainlink feeds return pB1*b1FeedPrecision, pB2*b2FeedPrecision, pQ1*q1FeedPrecision and pQ2*q2FeedPrecision.
        // `price()` should return 1e36 * (pB1/1e(b1Decimals) * pB2/1e(b2Decimals)) / (pQ1/1e(q1Decimals) *
        // pQ2/1e(q2Decimals))
        // Yet `price()` returns (pB1*1e(b1FeedPrecision) * pB2*1e(b2FeedPrecision) * SCALE_FACTOR) /
        // (pQ1*1e(q1FeedPrecision) * pQ2*1e(q2FeedPrecision))
        // So 1e36 * (pB1/1e(b1Decimals) * pB2/1e(b2Decimals)) / (pQ1/1e(q1Decimals) * pQ2/1e(q2Decimals)) =
        // (pB1*1e(b1FeedPrecision) * pB2*1e(b2FeedPrecision) * SCALE_FACTOR) / (pQ1*1e(q1FeedPrecision) *
        // pQ2*1e(q2FeedPrecision))
        // So SCALE_FACTOR = 1e36 / 1e(b1Decimals) / 1e(b2Decimals) * 1e(q1Decimals) * 1e(q2Decimals) *
        // 1e(q1FeedPrecision) * 1e(q2FeedPrecision) / 1e(b1FeedPrecision) / 1e(b2FeedPrecision)
        //                 = 1e(36 + q1Decimals + q2Decimals + q1FeedPrecision + q2FeedPrecision - b1Decimals -
        // b2Decimals - b1FeedPrecision - b2FeedPrecision)
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + quoteFeed1.getDecimals() + quoteFeed2.getDecimals() - baseTokenDecimals
                    - baseFeed1.getDecimals() - baseFeed2.getDecimals() - CONVERSION_SAMPLE_DECIMALS
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (VAULT.getAssets(CONVERSION_SAMPLE) * BASE_FEED_1.getPrice() * BASE_FEED_2.getPrice() * SCALE_FACTOR)
            / (QUOTE_FEED_1.getPrice() * QUOTE_FEED_2.getPrice());
    }
}
