// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "morpho-blue/interfaces/IOracle.sol";

import {AggregatorV3Interface, DataFeedLib} from "./libraries/DataFeedLib.sol";

interface ERC4626 {
    function convertToAssets(uint256) external view returns (uint256);
}

contract OracleNonRebasing is IOracle {
    using DataFeedLib for AggregatorV3Interface;

    /* CONSTANT */

    /// @notice Vault.
    ERC4626 public immutable VAULT;
    /// @notice Vault decimals.
    uint256 public immutable VAULT_DECIMALS;
    /// @notice Base feed.
    AggregatorV3Interface public immutable BASE_FEED;
    /// @notice Quote feed.
    AggregatorV3Interface public immutable QUOTE_FEED;
    /// @notice Price scale factor.
    uint256 public immutable SCALE_FACTOR;

    /* CONSTRUCTOR */

    /// @param vault Vault.
    /// @param baseFeed Base feed.
    /// @param quoteFeed Quote feed. Pass address zero if the price = 1.
    /// @param vaultDecimals Vault decimals.
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        ERC4626 vault,
        AggregatorV3Interface baseFeed,
        AggregatorV3Interface quoteFeed,
        uint256 vaultDecimals,
        uint256 quoteTokenDecimals
    ) {
        VAULT = vault;
        BASE_FEED = baseFeed;
        QUOTE_FEED = quoteFeed;
        VAULT_DECIMALS = vaultDecimals;
        SCALE_FACTOR = 10 ** (36 + quoteFeed.wrapDecimals() - baseFeed.wrapDecimals() - quoteTokenDecimals);
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return (VAULT.convertToAssets(10 ** VAULT_DECIMALS) * BASE_FEED.wrapPrice() * SCALE_FACTOR)
            / QUOTE_FEED.wrapPrice();
    }
}
