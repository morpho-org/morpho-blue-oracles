// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function computeScaleFactor(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) external returns (uint256) envfree;
}

// Checks that every successful scale factor computation returns a non-zero value.
rule scaleFactorCannotBeZero(uint256 quoteTokenDecimals, uint256 quoteFeed1Decimals, uint256 quoteFeed2Decimals, uint256 baseTokenDecimals, uint256 baseFeed1Decimals, uint256 baseFeed2Decimals, uint256 quoteVaultConversionSample, uint256 baseVaultConversionSample) {
    uint256 scaleFactor = computeScaleFactor@withrevert(quoteTokenDecimals, quoteFeed1Decimals, quoteFeed2Decimals, baseTokenDecimals, baseFeed1Decimals, baseFeed2Decimals, quoteVaultConversionSample, baseVaultConversionSample);

    require !lastReverted;

    assert scaleFactor != 0, "scale factor is zero after a successful computation";
}
