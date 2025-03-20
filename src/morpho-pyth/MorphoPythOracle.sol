// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorphoPythOracle} from "./interfaces/IMorphoPythOracle.sol";
import {Math} from "../../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";
import {PythErrorsLib} from "./libraries/PythErrorsLib.sol";
import {PythFeedLib} from "./libraries/PythFeedLib.sol";

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract MorphoPythOracle is IMorphoPythOracle {
    using Math for uint256;
    IPyth public immutable pyth;
    using VaultLib for IERC4626;

    /* IMMUTABLES */

    IERC4626 public immutable BASE_VAULT;
    uint256 public immutable BASE_VAULT_CONVERSION_SAMPLE;

    IERC4626 public immutable QUOTE_VAULT;
    uint256 public immutable QUOTE_VAULT_CONVERSION_SAMPLE;

    bytes32 public immutable BASE_FEED_1;
    bytes32 public immutable BASE_FEED_2;
    bytes32 public immutable QUOTE_FEED_1;
    bytes32 public immutable QUOTE_FEED_2;

    uint256 public immutable SCALE_FACTOR;

    uint256 public PRICE_FEED_MAX_AGE;

    constructor(
        address pyth_,
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
        uint256 priceFeedMaxAge
    ) {
        require(
            address(baseVault) != address(0) || baseVaultConversionSample == 1,
            PythErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE
        );
        require(
            address(quoteVault) != address(0) ||
                quoteVaultConversionSample == 1,
            PythErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE
        );
        require(
            baseVaultConversionSample != 0,
            PythErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO
        );
        require(
            quoteVaultConversionSample != 0,
            PythErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO
        );
        BASE_VAULT = baseVault;
        BASE_VAULT_CONVERSION_SAMPLE = baseVaultConversionSample;
        QUOTE_VAULT = quoteVault;
        QUOTE_VAULT_CONVERSION_SAMPLE = quoteVaultConversionSample;
        BASE_FEED_1 = baseFeed1;
        BASE_FEED_2 = baseFeed2;
        QUOTE_FEED_1 = quoteFeed1;
        QUOTE_FEED_2 = quoteFeed2;
        
        pyth = IPyth(pyth_);
        SCALE_FACTOR =
            (10 **
                (36 +
                    quoteTokenDecimals +
                    PythFeedLib.getDecimals(pyth, QUOTE_FEED_1) +
                    PythFeedLib.getDecimals(pyth, QUOTE_FEED_2) -
                    baseTokenDecimals -
                    PythFeedLib.getDecimals(pyth, BASE_FEED_1) -
                    PythFeedLib.getDecimals(pyth, BASE_FEED_2)) *
                quoteVaultConversionSample) /
            baseVaultConversionSample;

        PRICE_FEED_MAX_AGE = priceFeedMaxAge;
    }

    function price() external view returns (uint256) {
        return
            SCALE_FACTOR.mulDiv(
                BASE_VAULT.getAssets(BASE_VAULT_CONVERSION_SAMPLE) *
                    PythFeedLib.getPrice(pyth, BASE_FEED_1, PRICE_FEED_MAX_AGE) *
                    PythFeedLib.getPrice(pyth, BASE_FEED_2, PRICE_FEED_MAX_AGE),
                QUOTE_VAULT.getAssets(QUOTE_VAULT_CONVERSION_SAMPLE) *
                    PythFeedLib.getPrice(pyth, QUOTE_FEED_1, PRICE_FEED_MAX_AGE) *
                    PythFeedLib.getPrice(pyth, QUOTE_FEED_2, PRICE_FEED_MAX_AGE)
            );
    }
}
