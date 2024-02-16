// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IChainlinkOracle} from "./interfaces/IChainlinkOracle.sol";
import {IChainlinkOracleFactory} from "./interfaces/IChainlinkOracleFactory.sol";
import {AggregatorV3Interface} from "./libraries/ChainlinkDataFeedLib.sol";
import {IERC4626} from "./libraries/VaultLib.sol";

import {ChainlinkOracle} from "./ChainlinkOracle.sol";

/// @title ChainlinkOracleFactory
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice This contract allows to create Chainlink oracles, and to index them easily.
contract ChainlinkOracleFactory is IChainlinkOracleFactory {
    /// @notice Emitted when a new Chainlink oracle is created.
    /// @param oracle The address of the Chainlink oracle.
    /// @param caller The caller of the function.
    /// @param baseVault Base vault.
    /// @param baseVaultConversionSample The sample amount of base vault shares used to convert to underlying.
    /// @param quoteVault Quote vault.
    /// @param quoteVaultConversionSample The sample amount of quote vault shares used to convert to underlying.
    /// @param salt The salt used for the MetaMorpho vault's CREATE2 address.
    event CreateChainlinkOracle(
        address oracle,
        address caller,
        address baseVault,
        uint256 baseVaultConversionSample,
        address quoteVault,
        uint256 quoteVaultConversionSample,
        bytes32 salt
    );

    /// @notice Emitted when a new Chainlink oracle is created.
    /// @param oracle The address of the Chainlink oracle.
    /// @param baseFeed1 First base feed.
    /// @param baseFeed2 Second base feed.
    /// @param quoteFeed1 First quote feed.
    /// @param quoteFeed2 Second quote feed.
    /// @param baseTokenDecimals Base token decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    event CreateChainlinkOracleFeeds(
        address oracle,
        address baseFeed1,
        address baseFeed2,
        address quoteFeed1,
        address quoteFeed2,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    );

    /* STORAGE */

    /// @inheritdoc IChainlinkOracleFactory
    mapping(address => bool) public isChainlinkOracle;

    /* EXTERNAL */

    /// @inheritdoc IChainlinkOracleFactory
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
    ) external returns (IChainlinkOracle oracle) {
        oracle = IChainlinkOracle(
            address(
                new ChainlinkOracle{salt: salt}(
                    baseVault,
                    baseVaultConversionSample,
                    quoteVault,
                    quoteVaultConversionSample,
                    baseFeed1,
                    baseFeed2,
                    quoteFeed1,
                    quoteFeed2,
                    baseTokenDecimals,
                    quoteTokenDecimals
                )
            )
        );

        isChainlinkOracle[address(oracle)] = true;

        emit CreateChainlinkOracle(
            address(oracle),
            msg.sender,
            address(baseVault),
            baseVaultConversionSample,
            address(quoteVault),
            quoteVaultConversionSample,
            salt
        );
        emit CreateChainlinkOracleFeeds(
            address(oracle),
            address(baseFeed1),
            address(baseFeed2),
            address(quoteFeed1),
            address(quoteFeed2),
            baseTokenDecimals,
            quoteTokenDecimals
        );
    }
}
