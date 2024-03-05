// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IOracle} from "../../lib/morpho-blue/src/interfaces/IOracle.sol";
import {IMorphoChainlinkOracleV2} from "./interfaces/IMorphoChainlinkOracleV2.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";
import {Math} from "../../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {AggregatorV3Interface, ChainlinkDataFeedLib} from "./libraries/ChainlinkDataFeedLib.sol";

/// @title MorphoChainlinkOracleV2
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Morpho Blue oracle using Chainlink-compliant feeds.
contract MorphoChainlinkOracleV2 is IMorphoChainlinkOracleV2 {
    using Math for uint256;
    using VaultLib for IERC4626;
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    /* IMMUTABLES */

    /// @inheritdoc IMorphoChainlinkOracleV2
    IERC4626 public immutable BASE_VAULT;

    /// @inheritdoc IMorphoChainlinkOracleV2
    uint256 public immutable BASE_VAULT_CONVERSION_SAMPLE;

    /// @inheritdoc IMorphoChainlinkOracleV2
    IERC4626 public immutable QUOTE_VAULT;

    /// @inheritdoc IMorphoChainlinkOracleV2
    uint256 public immutable QUOTE_VAULT_CONVERSION_SAMPLE;

    /// @inheritdoc IMorphoChainlinkOracleV2
    AggregatorV3Interface public immutable BASE_FEED_1;

    /// @inheritdoc IMorphoChainlinkOracleV2
    AggregatorV3Interface public immutable BASE_FEED_2;

    /// @inheritdoc IMorphoChainlinkOracleV2
    AggregatorV3Interface public immutable QUOTE_FEED_1;

    /// @inheritdoc IMorphoChainlinkOracleV2
    AggregatorV3Interface public immutable QUOTE_FEED_2;

    /// @inheritdoc IMorphoChainlinkOracleV2
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @dev Here is the list of assumptions that guarantees the oracle behaves as expected:
    /// - The vaults, if set, are ERC4626-compliant.
    /// - The feeds, if set, are Chainlink-interface-compliant.
    /// - Decimals passed as argument are correct.
    /// - The base vaults's sample shares quoted as assets and the base feed prices don't overflow when multiplied.
    /// - The quote vault's sample shares quoted as assets and the quote feed prices don't overflow when multiplied.
    /// @param baseVault Base vault. Pass address zero to omit this parameter.
    /// @param baseVaultConversionSample The sample amount of base vault shares used to convert to underlying.
    /// Pass 1 if the base asset is not a vault. Should be chosen such that converting `baseVaultConversionSample` to
    /// assets has enough precision.
    /// @param baseFeed1 First base feed. Pass address zero if the price = 1.
    /// @param baseFeed2 Second base feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteVault Quote vault. Pass address zero to omit this parameter.
    /// @param quoteVaultConversionSample The sample amount of quote vault shares used to convert to underlying.
    /// Pass 1 if the quote asset is not a vault. Should be chosen such that converting `quoteVaultConversionSample` to
    /// assets has enough precision.
    /// @param quoteFeed1 First quote feed. Pass address zero if the price = 1.
    /// @param quoteFeed2 Second quote feed. Pass address zero if the price = 1.
    /// @param quoteTokenDecimals Quote token decimals.
    /// @dev The base asset should be the collateral token and the quote asset the loan token.
    constructor(
        IERC4626 baseVault,
        uint256 baseVaultConversionSample,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        uint256 baseTokenDecimals,
        IERC4626 quoteVault,
        uint256 quoteVaultConversionSample,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 quoteTokenDecimals
    ) {
        // The ERC4626 vault parameters are used to price their respective conversion samples of their respective
        // shares, so it requires multiplying by `QUOTE_VAULT_CONVERSION_SAMPLE` and dividing
        // by `BASE_VAULT_CONVERSION_SAMPLE` in the `SCALE_FACTOR` definition.
        // Verify that vault = address(0) => vaultConversionSample = 1 for each vault.
        require(
            address(baseVault) != address(0) || baseVaultConversionSample == 1,
            ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE
        );
        require(
            address(quoteVault) != address(0) || quoteVaultConversionSample == 1,
            ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE
        );
        require(baseVaultConversionSample != 0, ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO);
        require(quoteVaultConversionSample != 0, ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO);

        BASE_VAULT = baseVault;
        BASE_VAULT_CONVERSION_SAMPLE = baseVaultConversionSample;
        QUOTE_VAULT = quoteVault;
        QUOTE_VAULT_CONVERSION_SAMPLE = quoteVaultConversionSample;
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;

        // In the following comment, we explain the general case (where we assume that no feed is the address zero)
        // how to scale the output price as Morpho Blue expects, given the input feed prices.
        // Similar explanations would hold in the case where some of the feeds are the address zero.

        // Let B1, B2, Q1, Q2, C be 5 assets, each respectively having dB1, dB2, dQ1, dQ2, dC decimals.
        // Let pB1 and pB2 be the base prices, and pQ1 and pQ2 the quote prices, so that:
        // - pB1 is the quantity of 1e(dB2) assets B2 that can be exchanged for 1e(dB1) assets B1.
        // - pB2 is the quantity of 1e(dC) assets C that can be exchanged for 1e(dB2) assets B2.
        // - pQ1 is the quantity of 1e(dQ2) assets Q2 that can be exchanged for 1e(dQ1) assets Q1.
        // - pQ2 is the quantity of 1e(dC) assets C that can be exchanged for 1e(dQ2) assets B2.

        // Morpho Blue expects `price()` to be the quantity of 1 asset Q1 that can be exchanged for 1 asset B1,
        // scaled by 1e36:
        // 1e36 * (pB1 * 1e(dB2 - dB1)) * (pB2 * 1e(dC - dB2)) / ((pQ1 * 1e(dQ2 - dQ1)) * (pQ2 * 1e(dC - dQ2)))
        // = 1e36 * (pB1 * 1e(-dB1) * pB2) / (pQ1 * 1e(-dQ1) * pQ2)

        // Let fpB1, fpB2, fpQ1, fpQ2 be the feed precision of the respective prices pB1, pB2, pQ1, pQ2.
        // Feeds return pB1 * 1e(fpB1), pB2 * 1e(fpB2), pQ1 * 1e(fpQ1) and pQ2 * 1e(fpQ2).

        // Based on the implementation of `price()` below, the value of `SCALE_FACTOR` should thus satisfy:
        // (pB1 * 1e(fpB1)) * (pB2 * 1e(fpB2)) * SCALE_FACTOR / ((pQ1 * 1e(fpQ1)) * (pQ2 * 1e(fpQ2)))
        // = 1e36 * (pB1 * 1e(-dB1) * pB2) / (pQ1 * 1e(-dQ1) * pQ2)

        // So SCALE_FACTOR = 1e36 * 1e(-dB1) * 1e(dQ1) * 1e(-fpB1) * 1e(-fpB2) * 1e(fpQ1) * 1e(fpQ2)
        //                 = 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2)
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + quoteFeed1.getDecimals() + quoteFeed2.getDecimals() - baseTokenDecimals
                    - baseFeed1.getDecimals() - baseFeed2.getDecimals()
            ) * quoteVaultConversionSample / baseVaultConversionSample;
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return SCALE_FACTOR.mulDiv(
            BASE_VAULT.getAssets(BASE_VAULT_CONVERSION_SAMPLE) * BASE_FEED_1.getPrice() * BASE_FEED_2.getPrice(),
            QUOTE_VAULT.getAssets(QUOTE_VAULT_CONVERSION_SAMPLE) * QUOTE_FEED_1.getPrice() * QUOTE_FEED_2.getPrice()
        );
    }
}
