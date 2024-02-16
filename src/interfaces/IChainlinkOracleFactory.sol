// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IChainlinkOracle} from "./IChainlinkOracle.sol";
import {IERC4626} from "../libraries/VaultLib.sol";
import {AggregatorV3Interface} from "../libraries/ChainlinkDataFeedLib.sol";

/// @title IChainlinkOracleFactory
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Interface of Chainkink Oracle's factory.
interface IChainlinkOracleFactory {
    /// @notice Whether a Chainlink oracle vault was created with the factory.
    function isChainlinkOracle(address target) external view returns (bool);

    /// @dev Here is the list of assumptions that guarantees the oracle behaves as expected:
    /// - Feeds are either Chainlink-compliant or the address zero.
    /// - Feeds have the same behavioral assumptions as Chainlink's.
    /// - Feeds are set in the correct order.
    /// - Decimals passed as argument are correct.
    /// - The vault's sample shares quoted as assets and the base feed prices don't overflow when multiplied.
    /// - The quote feed prices don't overflow when multiplied.
    /// - The vault, if set, is ERC4626-compliant.
    /// @param baseVault Base vault. Pass address zero to omit this parameter.
    /// @param baseVaultConversionSample The sample amount of base vault shares used to convert to underlying.
    /// Pass 1 if the base asset is not a vault. Should be chosen such that converting `baseVaultConversionSample` to
    /// assets has enough precision.
    /// @param quoteVault Quote vault. Pass address zero to omit this parameter.
    /// @param quoteVaultConversionSample The sample amount of quote vault shares used to convert to underlying.
    /// Pass 1 if the base asset is not a vault. Should be chosen such that converting `quoteVaultConversionSample` to
    /// assets has enough precision.
    /// @param baseFeed1 First base feed. Pass address zero if the price = 1.
    /// @param baseFeed2 Second base feed. Pass address zero if the price = 1.
    /// @param quoteFeed1 First quote feed. Pass address zero if the price = 1.
    /// @param quoteFeed2 Second quote feed. Pass address zero if the price = 1.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    /// @param salt The salt to use for the MetaMorpho vault's CREATE2 address.
    function createChainlinkOracle(
        IERC4626 baseVault,
        uint256 baseVaultConversionSample,
        IERC4626 quoteVault,
        uint256 quoteVaultConversionSample,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals,
        bytes32 salt
    ) external returns (IChainlinkOracle oracle);
}
