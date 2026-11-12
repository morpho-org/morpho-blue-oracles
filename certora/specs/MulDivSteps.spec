// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

methods {
    function MulDivHarness.product(uint256 x, uint256 y) internal returns (uint256, uint256) => productSummary(x, y);
    function MulDivHarness.subtract(uint256 hi, uint256 lo, uint256 r) internal returns (uint256, uint256) => subtractSummary(hi, lo, r);
    function MulDivHarness.twos(uint256 d) internal returns (uint256, uint256, uint256) => twosSummary(d);
    function MulDivHarness.shift(uint256 hi, uint256 lo, uint256 t, uint256 flipped) internal returns (uint256) => shiftSummary(hi, lo, t, flipped);
    function MulDivHarness.seed(uint256 d) internal returns (uint256) => seedSummary(d);
    function MulDivHarness.newton(uint256 d, uint256 inv) internal returns (uint256) => newtonSummary(d, inv);
    function MulDivHarness.finalProduct(uint256 lo, uint256 inv) internal returns (uint256) => finalSummary(lo, inv);
}

persistent ghost mathint originalD;

persistent ghost mathint quotient;

persistent ghost mathint oddPart;

// Non-reverting: MulDivLemmas.productNeverReverts.
function productSummary(uint256 x, uint256 y) returns (uint256, uint256) {
    uint256 hi;
    uint256 lo;
    require hi == x * y / B() && lo == x * y % B(), "MulDivLemmas.productCorrect";
    return (hi, lo);
}

// Non-reverting: MulDivLemmas.subtractNeverReverts.
function subtractSummary(uint256 hi, uint256 lo, uint256 r) returns (uint256, uint256) {
    uint256 newHi;
    uint256 newLo;
    require r <= hi * B() + lo => newHi * B() + newLo == hi * B() + lo - r, "MulDivLemmas.subtractCorrect";
    return (newHi, newLo);
}

// Non-reverting: MulDivLemmas.twosNeverReverts.
function twosSummary(uint256 d) returns (uint256, uint256, uint256) {
    uint256 odd;
    uint256 t;
    uint256 flipped;
    require d > 0 => wordTwosPost(d, odd, t, flipped), "BitsLemmas.twosWord";
    require d > 0 => flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0, "BitsLemmas.twosPower";
    oddPart = odd;
    return (odd, t, flipped);
}

// Non-reverting: MulDivLemmas.shiftNeverReverts.
function shiftSummary(uint256 hi, uint256 lo, uint256 t, uint256 flipped) returns uint256 {
    uint256 result;
    uint256 high = finalProduct(hi, flipped);
    require wordShiftPre(t, flipped) && (flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0) => result == lo / t + high, "MulDivLemmas.shiftWord";
    require wordShiftPre(t, flipped) => lo / t + (hi * flipped) % B() == ((hi * B() + lo) / t) % B(), "MulDivLemmas.shiftArithmetic";
    assert originalD >= 0 && quotient >= 0 && t > 0 && originalD % t == 0 => (originalD * quotient) / t == (originalD / t) * quotient, "hint";
    assert hi * B() + lo == originalD * quotient, "hint";
    assert result == ((hi * B() + lo) / t) % B(), "hint";
    assert result == (oddPart * quotient) % B(), "hint";
    return result;
}

// Non-reverting: MulDivLemmas.seedNeverReverts.
function seedSummary(uint256 d) returns uint256 {
    uint256 inv;
    mathint residue = mulmod(d, inv, 16);
    require d % 2 == 1 => residue == 1, "BitsLemmas.seedWord";
    return inv;
}

// Non-reverting: MulDivLemmas.newtonNeverReverts.
function newtonSummary(uint256 d, uint256 inv) returns uint256 {
    uint256 next;
    require d % 2 == 1 && (d * inv) % (2 ^ 4) == 1 => (d * next) % (2 ^ 8) == 1, "MulDivLemmas.newton4";
    require d % 2 == 1 && (d * inv) % (2 ^ 8) == 1 => (d * next) % (2 ^ 16) == 1, "MulDivLemmas.newton8";
    require d % 2 == 1 && (d * inv) % (2 ^ 16) == 1 => (d * next) % (2 ^ 32) == 1, "MulDivLemmas.newton16";
    require d % 2 == 1 && (d * inv) % (2 ^ 32) == 1 => (d * next) % (2 ^ 64) == 1, "MulDivLemmas.newton32";
    require d % 2 == 1 && (d * inv) % (2 ^ 64) == 1 => (d * next) % (2 ^ 128) == 1, "MulDivLemmas.newton64";
    require d % 2 == 1 && (d * inv) % (2 ^ 128) == 1 => (d * next) % B() == 1, "MulDivLemmas.newton128";
    return next;
}

// Non-reverting: MulDivLemmas.finalProductNeverReverts.
function finalSummary(uint256 lo, uint256 inv) returns uint256 {
    uint256 result;
    require result == (lo * inv) % B(), "MulDivLemmas.finalProductCorrect";
    require oddPart >= 0 && quotient >= 0 && inv >= 0 && B() == B() && (oddPart * inv) % B() == 1 => (((oddPart * quotient) % B()) * inv) % B() == quotient % B(), "MulDivLemmas.finalProductCancelInverse";
    return result;
}

/// mulDivSteps

// Check the split implementation's exact revert condition using the separately checked block lemmas.
rule mulDivStepsReverts(uint256 x, uint256 y, uint256 d) {
    originalD = d;
    quotient = d == 0 ? 0 : x * y / d;
    assert x * y >= 0 && d > 0 => x * y - (x * y) % d == d * (x * y / d), "hint";

    mulDivSteps@withrevert(x, y, d);

    assert lastReverted <=> d == 0 || x * y / d >= B();
}

// Check that the summarized blocks return the exact bounded floor quotient.
rule mulDivStepsValue(uint256 x, uint256 y, uint256 d) {
    originalD = d;
    quotient = d == 0 ? 0 : x * y / d;
    assert x * y >= 0 && d > 0 => x * y - (x * y) % d == d * (x * y / d), "hint";

    uint256 result = mulDivSteps@withrevert(x, y, d);

    assert !lastReverted => result == x * y / d;
}
