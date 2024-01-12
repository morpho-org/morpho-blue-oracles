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
    /// @param vault Vault.
    /// @param vaultConversionSample The sample amount of vault shares used to convert to the underlying asset.
    /// @param salt The salt used for the MetaMorpho vault's CREATE2 address.
    event CreateChainlinkOracle(
        address oracle, address caller, address vault, uint256 vaultConversionSample, bytes32 salt
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
        IERC4626 vault,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 vaultConversionSample,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals,
        bytes32 salt
    ) external returns (IChainlinkOracle oracle) {
        oracle = IChainlinkOracle(
            address(
                new ChainlinkOracle{salt: salt}(
                    vault,
                    baseFeed1,
                    baseFeed2,
                    quoteFeed1,
                    quoteFeed2,
                    vaultConversionSample,
                    baseTokenDecimals,
                    quoteTokenDecimals
                )
            )
        );

        isChainlinkOracle[address(oracle)] = true;

        emit CreateChainlinkOracle(address(oracle), msg.sender, address(vault), vaultConversionSample, salt);
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
