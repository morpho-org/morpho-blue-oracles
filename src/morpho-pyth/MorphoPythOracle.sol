// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IOracle} from "../../lib/morpho-blue/src/interfaces/IOracle.sol";
import {Math} from "../../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {IERC4626, VaultLib} from "./libraries/VaultLib.sol";
import {PythErrorsLib} from "./libraries/PythErrorsLib.sol";

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract MorphoPythOracle is IOracle {
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

        PythStructs.Price memory baseFeed1Price = pyth.getPriceUnsafe(
            BASE_FEED_1
        );
        PythStructs.Price memory baseFeed2Price = pyth.getPriceUnsafe(
            BASE_FEED_2
        );
        PythStructs.Price memory quoteFeed1Price = pyth.getPriceUnsafe(
            QUOTE_FEED_1
        );
        PythStructs.Price memory quoteFeed2Price = pyth.getPriceUnsafe(
            QUOTE_FEED_2
        );

        SCALE_FACTOR =
            (10 **
                (36 +
                    quoteTokenDecimals +
                    uint256(-1 * int256(quoteFeed1Price.expo)) +
                    uint256(-1 * int256(quoteFeed2Price.expo)) -
                    baseTokenDecimals -
                    uint256(-1 * int256(baseFeed1Price.expo)) -
                    uint256(-1 * int256(baseFeed2Price.expo))) *
                quoteVaultConversionSample) /
            baseVaultConversionSample;

        PRICE_FEED_MAX_AGE = priceFeedMaxAge;
    }

    function price() external view returns (uint256) {
        uint256 baseFeed1Price;
        uint256 baseFeed2Price;
        uint256 quoteFeed1Price;
        uint256 quoteFeed2Price;
        PythStructs.Price memory latestPrice;

        if (BASE_FEED_1 == bytes32(0)) {
            baseFeed1Price = 1;
        } else {
            latestPrice = pyth.getPriceNoOlderThan(
                BASE_FEED_1,
                PRICE_FEED_MAX_AGE
            );
            baseFeed1Price = uint256(int256(latestPrice.price));
        }

        if (BASE_FEED_2 == bytes32(0)) {
            baseFeed2Price = 1;
        } else {
            latestPrice = pyth.getPriceNoOlderThan(
                BASE_FEED_2,
                PRICE_FEED_MAX_AGE
            );
            baseFeed2Price = uint256(int256(latestPrice.price));
        }

        if (QUOTE_FEED_1 == bytes32(0)) {
            quoteFeed1Price = 1;
        } else {
            latestPrice = pyth.getPriceNoOlderThan(
                QUOTE_FEED_1,
                PRICE_FEED_MAX_AGE
            );

            quoteFeed1Price = uint256(int256(latestPrice.price));
        }

        if (QUOTE_FEED_2 == bytes32(0)) {
            quoteFeed2Price = 1;
        } else {
            latestPrice = pyth.getPriceNoOlderThan(
                QUOTE_FEED_2,
                PRICE_FEED_MAX_AGE
            );
            quoteFeed2Price = uint256(int256(latestPrice.price));
        }
        return
            SCALE_FACTOR.mulDiv(
                BASE_VAULT.getAssets(BASE_VAULT_CONVERSION_SAMPLE) *
                    baseFeed1Price *
                    baseFeed2Price,
                QUOTE_VAULT.getAssets(QUOTE_VAULT_CONVERSION_SAMPLE) *
                    quoteFeed1Price *
                    quoteFeed2Price
            );
    }
}
