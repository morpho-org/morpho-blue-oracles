// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

methods {
    function MulDivHarness._product(uint256 x, uint256 y) internal returns (uint256, uint256) => productSummary(x, y);
    function MulDivHarness._subtract(uint256 hi, uint256 lo, uint256 r) internal returns (uint256, uint256) => subtractSummary(hi, lo, r);
    function MulDivHarness._twos(uint256 d) internal returns (uint256, uint256, uint256) => twosSummary(d);
    function MulDivHarness._shift(uint256 hi, uint256 lo, uint256 t, uint256 flipped) internal returns (uint256) => shiftSummary(hi, lo, t, flipped);
    function MulDivHarness._seed(uint256 d) internal returns (uint256) => seedSummary(d);
    function MulDivHarness._newton(uint256 d, uint256 inv) internal returns (uint256) => newtonSummary(d, inv);
    function MulDivHarness._final(uint256 lo, uint256 inv) internal returns (uint256) => finalSummary(lo, inv);
}

persistent ghost mathint originalD;

persistent ghost mathint quotient;

persistent ghost mathint oddPart;

function euclideanDivision(mathint n, mathint d) {
    assert n >= 0 && d > 0 => n - n % d == d * (n / d), "hint";
}

// Non-reverting: MulDivSummary.productNeverReverts.
function productSummary(uint256 x, uint256 y) returns (uint256, uint256) {
    uint256 hi;
    uint256 lo;
    require hi == x * y / B() && lo == x * y % B(), "MulDivSummary.highProduct";
    return (hi, lo);
}

// Non-reverting: MulDivSummary.subtractNeverReverts.
function subtractSummary(uint256 hi, uint256 lo, uint256 r) returns (uint256, uint256) {
    uint256 newHi;
    uint256 newLo;
    require r <= hi * B() + lo => newHi * B() + newLo == hi * B() + lo - r, "MulDivSummary.subtractProduct";
    return (newHi, newLo);
}

// Non-reverting: MulDivSummary.twosNeverReverts.
function twosSummary(uint256 d) returns (uint256, uint256, uint256) {
    uint256 odd;
    uint256 t;
    uint256 flipped;
    require d > 0 => wordTwosPost(d, odd, t, flipped), "MulDivSummaryBits.twosWord";
    require d > 0 => flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0, "MulDivSummaryBits.twosPower";
    oddPart = odd;
    return (odd, t, flipped);
}

// Non-reverting: MulDivSummary.shiftNeverReverts.
function shiftSummary(uint256 hi, uint256 lo, uint256 t, uint256 flipped) returns uint256 {
    uint256 result;
    uint256 high = finalProduct(hi, flipped);
    require wordShiftPre(t, flipped) && (flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0) => result == lo / t + high, "MulDivSummary.shiftWord";
    require wordShiftPre(t, flipped) => lo / t + (hi * flipped) % B() == ((hi * B() + lo) / t) % B(), "MulDivSummary.shiftArithmetic";
    assert originalD >= 0 && quotient >= 0 && t > 0 && originalD % t == 0 => (originalD * quotient) / t == (originalD / t) * quotient, "hint";
    assert hi * B() + lo == originalD * quotient, "hint";
    assert result == ((hi * B() + lo) / t) % B(), "hint";
    assert result == (oddPart * quotient) % B(), "hint";
    return result;
}

// Non-reverting: MulDivSummary.seedNeverReverts.
function seedSummary(uint256 d) returns uint256 {
    uint256 inv;
    uint256 residue = seedProduct(d, inv);
    require d % 2 == 1 => residue == 1, "MulDivSummaryBits.seedWord";
    return inv;
}

// Non-reverting: MulDivSummary.finalProductNeverReverts.
function finalSummary(uint256 lo, uint256 inv) returns uint256 {
    uint256 result;
    require result == (lo * inv) % B(), "MulDivSummary.finalProductCorrect";
    require oddPart >= 0 && quotient >= 0 && inv >= 0 && B() == B() && (oddPart * inv) % B() == 1 => (((oddPart * quotient) % B()) * inv) % B() == quotient % B(), "MulDivSummary.cancelModularInverse";
    return result;
}

// Non-reverting: MulDivSummary.newtonNeverReverts.
function newtonSummary(uint256 d, uint256 inv) returns uint256 {
    uint256 next;
    require d % 2 == 1 && (d * inv) % (2 ^ 4) == 1 => (d * next) % (2 ^ 8) == 1, "MulDivSummary.newton4";
    require d % 2 == 1 && (d * inv) % (2 ^ 8) == 1 => (d * next) % (2 ^ 16) == 1, "MulDivSummary.newton8";
    require d % 2 == 1 && (d * inv) % (2 ^ 16) == 1 => (d * next) % (2 ^ 32) == 1, "MulDivSummary.newton16";
    require d % 2 == 1 && (d * inv) % (2 ^ 32) == 1 => (d * next) % (2 ^ 64) == 1, "MulDivSummary.newton32";
    require d % 2 == 1 && (d * inv) % (2 ^ 64) == 1 => (d * next) % (2 ^ 128) == 1, "MulDivSummary.newton64";
    require d % 2 == 1 && (d * inv) % (2 ^ 128) == 1 => (d * next) % (2 ^ 256) == 1, "MulDivSummary.newton128";
    return next;
}

// Check the split implementation's exact revert condition using the separately checked block lemmas.
rule stepsReverts(uint256 x, uint256 y, uint256 d) {
    originalD = d;
    quotient = d == 0 ? 0 : x * y / d;
    euclideanDivision(x * y, d);
    mulDivSteps@withrevert(x, y, d);

    assert lastReverted <=> d == 0 || x * y / d >= B();
}

// Check that the summarized blocks return the exact bounded floor quotient.
rule stepsValue(uint256 x, uint256 y, uint256 d) {
    originalD = d;
    quotient = d == 0 ? 0 : x * y / d;
    euclideanDivision(x * y, d);
    uint256 result = mulDivSteps@withrevert(x, y, d);

    assert !lastReverted => d != 0 && result == x * y / d;
}
