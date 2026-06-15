// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC4626} from "../../src/morpho-chainlink/interfaces/IERC4626.sol";

contract MorphoChainlinkOracleV2Harness {
    function deployAndGetScaleFactor(
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
    ) external returns (uint256) {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
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

        return oracle.SCALE_FACTOR();
    }
}
