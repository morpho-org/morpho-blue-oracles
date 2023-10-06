// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IOracle} from "../lib/morpho-blue/src/interfaces/IOracle.sol";

import {AggregatorV3Interface, ChainlinkDataFeedLib} from "./libraries/ChainlinkDataFeedLib.sol";

interface ERC4626 {
    function convertToAssets(uint256) external view returns (uint256);
    function decimals() external view returns (uint256);
}

contract Chainlink4626Oracle is IOracle {
    using ChainlinkDataFeedLib for AggregatorV3Interface;

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
    /// @param quoteTokenDecimals Quote token decimals.
    constructor(
        ERC4626 vault,
        AggregatorV3Interface baseFeed,
        AggregatorV3Interface quoteFeed,
        uint256 baseTokenDecimals,
        uint256 quoteTokenDecimals
    ) {
        VAULT = vault;
        BASE_FEED = baseFeed;
        QUOTE_FEED = quoteFeed;
        VAULT_DECIMALS = vault.decimals();
        // This scale factor is defined similarly to the scale factor of the ChainlinkOracle, except:
        // - the oracle only has one base feed and one quote feed
        // - it is used to price a full unit of the vault shares, so it requires dividing by that number, hence the
        // `vaultDecimals` subtraction
        SCALE_FACTOR = 10
            ** (
                36 + quoteTokenDecimals + quoteFeed.getDecimals() - baseFeed.getDecimals() - baseTokenDecimals
                    - VAULT_DECIMALS
            );
    }

    /* PRICE */

    /// @inheritdoc IOracle
    function price() external view returns (uint256) {
        return
            (VAULT.convertToAssets(10 ** VAULT_DECIMALS) * BASE_FEED.getPrice() * SCALE_FACTOR) / QUOTE_FEED.getPrice();
    }
}
