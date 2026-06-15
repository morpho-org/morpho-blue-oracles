// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC4626} from "../../src/morpho-chainlink/interfaces/IERC4626.sol";

contract MorphoChainlinkOracleV2Harness is MorphoChainlinkOracleV2 {
    constructor()
        MorphoChainlinkOracleV2(
            IERC4626(address(0)),
            1,
            AggregatorV3Interface(address(0)),
            AggregatorV3Interface(address(0)),
            0,
            IERC4626(address(0)),
            1,
            AggregatorV3Interface(address(0)),
            AggregatorV3Interface(address(0)),
            0
        )
    {}

    function computeScaleFactor(
        uint256 quoteTokenDecimals,
        uint256 quoteFeed1Decimals,
        uint256 quoteFeed2Decimals,
        uint256 baseTokenDecimals,
        uint256 baseFeed1Decimals,
        uint256 baseFeed2Decimals,
        uint256 quoteVaultConversionSample,
        uint256 baseVaultConversionSample
    ) external pure returns (uint256) {
        return _scaleFactor(
            quoteTokenDecimals,
            quoteFeed1Decimals,
            quoteFeed2Decimals,
            baseTokenDecimals,
            baseFeed1Decimals,
            baseFeed2Decimals,
            quoteVaultConversionSample,
            baseVaultConversionSample
        );
    }
}
