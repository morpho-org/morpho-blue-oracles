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

    /// @notice Creates a new Chainlink Oracle.
    /// @param vault Vault. Pass address zero to omit this parameter.
    /// @param baseFeed1 First base feed. Pass address zero if the price = 1.
    /// @param baseFeed2 Second base feed. Pass address zero if the price = 1.
    /// @param quoteFeed1 First quote feed. Pass address zero if the price = 1.
    /// @param quoteFeed2 Second quote feed. Pass address zero if the price = 1.
    /// @param vaultConversionSample The sample amount of vault shares used to convert to the underlying asset.
    /// Pass 1 if the oracle does not use a vault. Should be chosen such that converting `vaultConversionSample` to
    /// assets has enough precision.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    /// @param salt The salt to use for the MetaMorpho vault's CREATE2 address.
    function createChainlinkOracle(
        IERC4626 vault,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 vaultConversionSample,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals,
        bytes32 salt
    ) external returns (IChainlinkOracle oracle);
}
