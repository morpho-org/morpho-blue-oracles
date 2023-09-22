// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, ChainlinkDataFeedLib} from "./libraries/ChainlinkDataFeedLib.sol";
import {ERC4626, VaultDataFeedLib} from "./libraries/VaultDataFeedLib.sol";

/// @title ChainlinkOracle
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Morpho Blue oracle using Chainlink-compliant feeds.
contract ChainlinkOracle is IOracle {
    using VaultDataFeedLib for ERC4626;
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    /* IMMUTABLES */

    /// @notice Vault.
    ERC4626 public immutable VAULT;
    /// @notice Vault decimals.
    uint256 public immutable VAULT_DECIMALS;
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
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        ERC4626 vault,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        VAULT = vault;
        // TODO: adapt this
        // This scale factor is defined similarly to the scale factor of the ChainlinkOracle, except:
        // - the oracle only has one base feed and one quote feed
        // - it is used to price a full unit of the vault shares, so it requires dividing by that number, hence the
        // `VAULT_DECIMALS` subtraction
        VAULT_DECIMALS = VAULT.getDecimals();
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;
        // Let pB1 and pB2 be the base prices, and pQ1 and pQ2 the quote prices (price of 1e(decimals) asset), in a
        // common quote currency.
        // Chainlink feeds return pB1*b1FeedPrecision, pB2*b2FeedPrecision, pQ1*q1FeedPrecision and pQ2*q2FeedPrecision.
        // `price()` should return 1e36 * (pB1/1e(b1Decimals) * pB2/1e(b2Decimals)) / (pQ1/1e(q1Decimals) *
        // pQ2/1e(q2Decimals)).
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
                36 + quoteTokenDecimals + quoteFeed1.getDecimals() + quoteFeed2.getDecimals() - baseFeed1.getDecimals()
                    - baseFeed2.getDecimals() - baseTokenDecimals - VAULT_DECIMALS
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (VAULT.getAssets(10 ** VAULT_DECIMALS) * BASE_FEED_1.getPrice() * BASE_FEED_2.getPrice() * SCALE_FACTOR)
            / (QUOTE_FEED_1.getPrice() * QUOTE_FEED_2.getPrice());
    }
}
