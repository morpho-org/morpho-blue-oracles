// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorphoChainlinkOracleV2} from "./interfaces/IMorphoChainlinkOracleV2.sol";
import {IMorphoChainlinkOracleV2Factory} from "./interfaces/IMorphoChainlinkOracleV2Factory.sol";
import {AggregatorV3Interface} from "./libraries/ChainlinkDataFeedLib.sol";
import {IERC4626} from "./libraries/VaultLib.sol";

import {MorphoChainlinkOracleV2} from "./MorphoChainlinkOracleV2.sol";

/// @title MorphoChainlinkOracleV2Factory
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice This contract allows to create MorphoChainlinkOracleV2 oracles, and to index them easily.
contract MorphoChainlinkOracleV2Factory is IMorphoChainlinkOracleV2Factory {
    /* STORAGE */

    /// @inheritdoc IMorphoChainlinkOracleV2Factory
    mapping(address => bool) public isMorphoChainlinkOracleV2;

    /* EXTERNAL */

    /// @inheritdoc IMorphoChainlinkOracleV2Factory
    function createMorphoChainlinkOracleV2(
        IERC4626 baseVault,
        uint256 baseVaultConversionSample,
        AggregatorV3Interface baseFeed1,
        AggregatorV3Interface baseFeed2,
        uint256 baseTokenDecimals,
        IERC4626 quoteVault,
        uint256 quoteVaultConversionSample,
        AggregatorV3Interface quoteFeed1,
        AggregatorV3Interface quoteFeed2,
        uint256 quoteTokenDecimals,
        bytes32 salt
    ) external returns (MorphoChainlinkOracleV2 oracle) {
        oracle = new MorphoChainlinkOracleV2{salt: salt}(
            baseVault,
            baseVaultConversionSample,
            baseFeed1,
            baseFeed2,
            baseTokenDecimals,
            quoteVault,
            quoteVaultConversionSample,
            quoteFeed1,
            quoteFeed2,
            quoteTokenDecimals
        );

        isMorphoChainlinkOracleV2[address(oracle)] = true;

        emit CreateMorphoChainlinkOracleV2(msg.sender, address(oracle));
    }
}
