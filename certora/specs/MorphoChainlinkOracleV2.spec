// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function deployAndGetScaleFactor(address, uint256, address, address, uint256, address, uint256, address, address, uint256) external returns (uint256) envfree;
}

// Checks that every successful MorphoChainlinkOracleV2 deployment has a non-zero SCALE_FACTOR.
rule scaleFactorCannotBeZero(address baseVault, uint256 baseVaultConversionSample, address baseFeed1, address baseFeed2, uint256 baseTokenDecimals, address quoteVault, uint256 quoteVaultConversionSample, address quoteFeed1, address quoteFeed2, uint256 quoteTokenDecimals) {
    uint256 scaleFactor = deployAndGetScaleFactor@withrevert(baseVault, baseVaultConversionSample, baseFeed1, baseFeed2, baseTokenDecimals, quoteVault, quoteVaultConversionSample, quoteFeed1, quoteFeed2, quoteTokenDecimals);

    require !lastReverted;

    assert scaleFactor != 0, "scale factor is zero after a successful deployment";
}
