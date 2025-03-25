// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IERC4626} from "../libraries/VaultLib.sol";
import {IMorphoPythOracle} from "./IMorphoPythOracle.sol";

/// @title IMorphoPythOracleFactory
/// @author Pyth Data Association
/// @notice Interface for MorphoPythOracleFactory
interface IMorphoPythOracleFactory {
    /// @notice Emitted when a new Pyth oracle is created.
    /// @param oracle The address of the Pyth oracle.
    /// @param caller The caller of the function.
    event CreateMorphoPythOracle(address caller, address oracle);

    /// @notice Whether a Pyth oracle vault was created with the factory.
    function isMorphoPythOracle(address target) external view returns (bool);

    /// @dev Here is the list of assumptions that guarantees the oracle behaves as expected:
    /// - The pyth address is correct for the chain.
    /// - The vaults, if set, are ERC4626-compliant.
    /// - The feeds, if set, are Pyth Price Feeds fetched from https://www.pyth.network/developers/price-feed-ids.
    /// - Decimals passed as argument are correct.
    /// - The base vaults's sample shares quoted as assets and the base feed prices don't overflow when multiplied.
    /// - The quote vault's sample shares quoted as assets and the quote feed prices don't overflow when multiplied.
    /// - The price feed max age is in seconds.
    /// @param pyth The address of the Pyth contract deployed on the chain.
    /// @param baseVault Base vault. Pass address zero to omit this parameter.
    /// @param baseVaultConversionSample The sample amount of base vault shares used to convert to underlying.
    /// Pass 1 if the base asset is not a vault. Should be chosen such that converting `baseVaultConversionSample` to
    /// assets has enough precision.
    /// @param baseFeed1 First base feed. Pass bytes32(0) if the price = 1. We recommend using stablecoin feeds instead of passing 1.
    /// @param baseFeed2 Second base feed. Pass bytes32(0) if the price = 1. We recommend using stablecoin feeds instead of passing 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteVault Quote vault. Pass address zero to omit this parameter.
    /// @param quoteVaultConversionSample The sample amount of quote vault shares used to convert to underlying.
    /// Pass 1 if the quote asset is not a vault. Should be chosen such that converting `quoteVaultConversionSample` to
    /// assets has enough precision.
    /// @param quoteFeed1 First quote feed. Pass bytes32(0) if the price = 1. We recommend using stablecoin feeds instead of passing 1.
    /// @param quoteFeed2 Second quote feed. Pass bytes32(0) if the price = 1. We recommend using stablecoin feeds instead of passing 1.
    /// @param quoteTokenDecimals Quote token decimals.
    /// @param priceFeedMaxAge The maximum age in secondsfor the oracles prices to be considered valid.
    /// @param salt The salt to use for the CREATE2.
    /// @dev The base asset should be the collateral token and the quote asset the loan token.
    function createMorphoPythOracle(
        address pyth,
        IERC4626 baseVault,
        uint256 baseVaultConversionSample,
        bytes32 baseFeed1,
        bytes32 baseFeed2,
        uint256 baseTokenDecimals,
        IERC4626 quoteVault,
        uint256 quoteVaultConversionSample,
        bytes32 quoteFeed1,
        bytes32 quoteFeed2,
        uint256 quoteTokenDecimals,
        uint256 priceFeedMaxAge,
        bytes32 salt
    ) external returns (IMorphoPythOracle oracle);
}
