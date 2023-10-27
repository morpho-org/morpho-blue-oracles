// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {IOracle} from "../lib/morpho-blue/src/interfaces/IOracle.sol";

import {AggregatorV3Interface, ChainlinkDataFeedLib} from "./libraries/ChainlinkDataFeedLib.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";

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
    /// @notice Vault conversion sample. The sample amount of shares used to convert to the underlying asset.
    /// @notice Should be chosen such that converting `VAULT_CONVERSION_SAMPLE` to assets has enough precision.
    uint256 public immutable VAULT_CONVERSION_SAMPLE;
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
    /// @param vaultConversionSample Vault conversion sample. Pass 1 if the oracle does not use a vault.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        IERC4626 vault,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 vaultConversionSample,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        // The vault parameter is used for ERC4626 tokens, to price its shares.
        // It is used to price `VAULT_CONVERSION_SAMPLE` of the vault shares, so it requires dividing by that number,
        // hence the division by `VAULT_CONVERSION_SAMPLE` in the `SCALE_FACTOR` definition.
        // Verify that vault = address(0) => vaultConversionSample = 1.
        require(
            address(vault) != address(0) || vaultConversionSample == 1, ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE
        );
        require(vaultConversionSample != 0, ErrorsLib.VAULT_CONVERSION_IS_ZERO);

        VAULT = vault;
        VAULT_CONVERSION_SAMPLE = vaultConversionSample;
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;
        // Let pB1 and pB2 be the base prices, and pQ1 and pQ2 the quote prices (price taking into account the
        // decimals of both tokens), in a common currency.
        // We tackle the most general case in the remainder of this comment, where we assume that no feed is the address
        // zero. Similar explanations would hold in the case where some of the feeds are the address zero.
        // Let dB1, dB2, dB3, and dQ1, dQ2, dQ3 be the decimals of the tokens involved.
        // For example, pB1 is the number of 1e(dB2) of the second base asset that can be obtained from 1e(dB1) of
        // the first base asset.
        // We notably have dB3 = dQ3, because those two quantities are the decimals of the same common currency.
        // Let fpB1, fpB2, fpQ1 and fpQ2 be the feed precision of the corresponding prices.
        // Chainlink feeds return pB1*1e(fpB1), pB2*1e(fpB2), pQ1*1e(fpQ1) and pQ2*1e(fpQ2).
        // Because the Blue oracle does not take into account decimals, `price()` should return
        // 1e36 * (pB1*1e(dB2-dB1) * pB2*1e(dB3-dB2)) / (pQ1*1e(dQ2-dQ1) * pQ2*1e(dQ3-dQ2))
        // Yet `price()` returns (pB1*1e(fpB1) * pB2*1e(fpB2) * SCALE_FACTOR) / (pQ1*1e(fpQ1) * pQ2*1e(fpQ2))
        // So 1e36 * pB1 * pB2 * 1e(-dB1) / (pQ1 * pQ2 * 1e(-dQ1)) =
        // (pB1*1e(fpB1) * pB2*1e(fpB2) * SCALE_FACTOR) / (pQ1*1e(fpQ1) * pQ2*1e(fpQ2))
        // So SCALE_FACTOR = 1e36 * 1e(-dB1) * 1e(dQ1) * 1e(-fpB1) * 1e(-fpB2) * 1e(fpQ1) * 1e(fpQ2)
        //                 = 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2)
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + quoteFeed1.getDecimals() + quoteFeed2.getDecimals() - baseTokenDecimals
                    - baseFeed1.getDecimals() - baseFeed2.getDecimals()
            ) / VAULT_CONVERSION_SAMPLE;
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (
            VAULT.getAssets(VAULT_CONVERSION_SAMPLE) * BASE_FEED_1.getPrice() * BASE_FEED_2.getPrice() * SCALE_FACTOR
        ) / (QUOTE_FEED_1.getPrice() * QUOTE_FEED_2.getPrice());
    }
}
