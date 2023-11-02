// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {IOracle} from "../lib/morpho-blue/src/interfaces/IOracle.sol";

import {AggregatorV3Interface, Quantity, ChainlinkDataFeedAltLib} from "./libraries/ChainlinkDataFeedAltLib.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title ChainlinkOracleAlt
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Morpho Blue oracle using Chainlink-compliant feeds.
contract ChainlinkOracleAlt is IOracle {
    using VaultLib for IERC4626;
    using ChainlinkDataFeedAltLib for AggregatorV3Interface;

    /* IMMUTABLES */

    /// @notice Vault.
    IERC4626 public immutable VAULT;
    /// @notice First base feed.
    AggregatorV3Interface public immutable BASE_FEED_1;
    uint256 public immutable BASE_TOKEN_1_DECIMALS;
    /// @notice Second base feed.
    AggregatorV3Interface public immutable BASE_FEED_2;
    uint256 public immutable BASE_TOKEN_2_DECIMALS;
    /// @notice First quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED_1;
    uint256 public immutable QUOTE_TOKEN_1_DECIMALS;
    /// @notice Second quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED_2;
    uint256 public immutable QUOTE_TOKEN_2_DECIMALS;
    /// @notice Denominator token decimals
    uint256 public immutable DENOMINATOR_TOKEN_DECIMALS;

    /* CONSTRUCTOR */

    constructor(
        IERC4626 vault,
        AggregatorV3Interface baseFeed1,
        uint256 baseToken1Decimals,
        AggregatorV3Interface baseFeed2,
        uint256 baseToken2Decimals,
        AggregatorV3Interface quoteFeed1,
        uint256 quoteToken1Decimals,
        AggregatorV3Interface quoteFeed2,
        uint256 quoteToken2Decimals,
        uint256 denominatorTokenDecimals
    ) {
        VAULT = vault;
        BASE_FEED_1 = baseFeed1;
        BASE_TOKEN_1_DECIMALS = baseToken1Decimals;
        BASE_FEED_2 = baseFeed2;
        BASE_TOKEN_2_DECIMALS = baseToken2Decimals;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_TOKEN_1_DECIMALS = quoteToken1Decimals;
        QUOTE_FEED_2 = quoteFeed2;
        QUOTE_TOKEN_2_DECIMALS = quoteToken2Decimals;
        DENOMINATOR_TOKEN_DECIMALS = denominatorTokenDecimals;
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        uint256 denominatorSample = 10 ** DENOMINATOR_TOKEN_DECIMALS;

        Quantity memory base = Quantity(denominatorSample, DENOMINATOR_TOKEN_DECIMALS);
        base = BASE_FEED_2.convert(base, BASE_TOKEN_2_DECIMALS);
        base = BASE_FEED_1.convert(base, BASE_TOKEN_1_DECIMALS);
        base.amount = address(VAULT) == address(0) ? base.amount : VAULT.convertToShares(base.amount);

        Quantity memory quote = Quantity(denominatorSample, DENOMINATOR_TOKEN_DECIMALS);
        quote = QUOTE_FEED_2.convert(quote, QUOTE_TOKEN_2_DECIMALS);
        quote = QUOTE_FEED_1.convert(quote, QUOTE_TOKEN_1_DECIMALS);

        return (10 ** 36 * quote.amount) / base.amount;
    }
}
