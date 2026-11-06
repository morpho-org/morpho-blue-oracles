// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

function modularPolynomial(mathint a, mathint b, mathint c, mathint m) {
    require m > 0 => (a * (b - c)) % m == ((a % m) * ((b - (c % m)) % m)) % m, "axiom: modular ring normalization; MulDivArithmetic.lean: MulDiv.modular_polynomial";
}

function divisibleProducts(mathint a, mathint b, mathint m) {
    require m > 0 && a % m == 0 && b % m == 0 => (a * b) % (m * m) == 0, "axiom: products of multiples; MulDivArithmetic.lean: MulDiv.divisible_products";
}

function orSummary(uint256 a, uint256 b, uint256 p) {
    require p > 0 && (p & assert_uint256(p - 1)) == 0 && a < p && b % p == 0 => (a | b) == a + b, "MulDivSummaryBits.powerOr";
}

// Check the real shift block using disjoint digits and explicit division witnesses.
rule shiftWord(uint256 hi, uint256 lo, uint256 t, uint256 flipped) {
    require wordShiftPre(t, flipped), "The divisor divides the word modulus and the flip is exact";
    require flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0, "MulDivSummaryBits.twosPower";
    uint256 high = finalProduct(hi, flipped);
    uint256 result = shift(hi, lo, t, flipped);
    assert high == (hi * flipped) % B();
    assert result == (assert_uint256(lo / t) | high);
    mathint u = max_uint256 / t + 1;
    assert B() == u * t;
    assert lo / t < u;
    mathint q = hi / t;
    mathint r = hi % t;
    assert hi == q * t + r;
    assert hi * u == q * B() + r * u;
    assert r * u < B();
    assert (hi * u) % B() == r * u;
    if (t == 1) {
        assert flipped == 0;
        assert high == 0;
        assert result == lo;
    } else {
        assert flipped == u;
        assert high == r * u;
        assert high % flipped == 0;
        orSummary(assert_uint256(lo / t), high, flipped);
    }
    assert lo / t + high < B();
    assert result == lo / t + high;
}

// Check shift reconstruction and no-wrap arithmetic without bitwise operations or axioms.
rule shiftArithmetic(uint256 hi, uint256 lo, uint256 t, uint256 flipped) {
    require wordShiftPre(t, flipped);
    mathint u = max_uint256 / t + 1;
    assert B() == u * t;
    assert u == B() / t;
    assert lo / t < u;
    mathint q = hi / t;
    mathint r = hi % t;
    assert hi == q * t + r;
    assert hi * u == q * B() + r * u;
    assert r * u < B();
    assert (hi * u) % B() == r * u;
    if (t == 1) {
        assert flipped == 0;
        assert (hi * flipped) % B() == r * u;
    } else {
        assert flipped == u;
        assert max_uint256 % flipped == flipped - 1;
        assert (hi * flipped) % B() == r * u;
    }
    assert ((hi * flipped) % B()) % u == 0;
    assert lo / t + (hi * flipped) % B() < B();
    mathint lowQ = lo / t;
    mathint lowR = lo % t;
    assert lo == lowQ * t + lowR;
    assert hi * B() + lo == (hi * u + lowQ) * t + lowR;
    assert (hi * B() + lo) / t == hi * u + lowQ;
    assert (hi * u + lowQ) % B() == r * u + lowQ;
    assert lo / t + (hi * flipped) % B() == ((hi * B() + lo) / t) % B();
}

// Check Newton precision doubling from 4 to 8 bits with explicit error and wrap witnesses.
rule newton4(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 4) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert (expression - next) % B() == 0;
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B();
    mathint error = (d * inv - 1) / (2 ^ 4);
    assert d * inv == 1 + (2 ^ 4) * error;
    assert d * expression == 1 - (2 ^ 8) * error * error;
    assert (d * next) % (2 ^ 8) == 1;
}

// Check Newton precision doubling from 8 to 16 bits with explicit error and wrap witnesses.
rule newton8(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 8) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert (expression - next) % B() == 0;
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B();
    mathint error = (d * inv - 1) / (2 ^ 8);
    assert d * inv == 1 + (2 ^ 8) * error;
    assert d * expression == 1 - (2 ^ 16) * error * error;
    assert (d * next) % (2 ^ 16) == 1;
}

// Check Newton precision doubling from 16 to 32 bits with explicit error and wrap witnesses.
rule newton16(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 16) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert (expression - next) % B() == 0;
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B();
    mathint error = (d * inv - 1) / (2 ^ 16);
    assert d * inv == 1 + (2 ^ 16) * error;
    assert d * expression == 1 - (2 ^ 32) * error * error;
    assert (d * next) % (2 ^ 32) == 1;
}

// Check Newton precision doubling from 32 to 64 bits with explicit error and wrap witnesses.
rule newton32(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 32) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert (expression - next) % B() == 0;
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B();
    mathint error = (d * inv - 1) / (2 ^ 32);
    assert d * inv == 1 + (2 ^ 32) * error;
    assert d * expression == 1 - (2 ^ 64) * error * error;
    assert (d * next) % (2 ^ 64) == 1;
}

// Check Newton precision doubling from 64 to 128 bits with explicit error and wrap witnesses.
rule newton64(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 64) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert (expression - next) % B() == 0;
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B();
    mathint error = (d * inv - 1) / (2 ^ 64);
    assert d * inv == 1 + (2 ^ 64) * error;
    assert d * expression == 1 - (2 ^ 128) * error * error;
    assert (d * next) % (2 ^ 128) == 1;
}

// Check Newton precision doubling from 128 to 256 bits by squaring the divisible error.
rule newton128(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 128) == 1, "The preceding iteration supplies the current inverse precision";
    uint256 next = newton(d, inv);
    mathint expression = inv * (2 - d * inv);
    modularPolynomial(inv, 2, d * inv, B());
    assert next == expression % B();
    mathint error = d * inv - 1;
    assert error % (2 ^ 128) == 0;
    divisibleProducts(error, error, 2 ^ 128);
    assert d * expression == 1 - error * error;
    assert (d * expression) % B() == 1;
    modularPolynomial(d, expression, 0, B());
    assert (d * next) % B() == 1;
}

// Check that the split implementation has the same revert and return behavior without summaries.
rule stepsEquivalent(uint256 x, uint256 y, uint256 d) {
    uint256 actual = mulDiv@withrevert(x, y, d);
    bool actualReverted = lastReverted;
    uint256 split = mulDivSteps@withrevert(x, y, d);
    bool splitReverted = lastReverted;
    assert actualReverted == splitReverted;
    assert !actualReverted && !splitReverted => actual == split;
}

// Check high_product: the CRT block reconstructs both limbs of the exact product.
rule highProduct(uint256 x, uint256 y) {
    uint256 hi;
    uint256 lo;
    hi, lo = product(x, y);
    assert hi == x * y / B();
    assert lo == x * y % B();
}

// Check subtract_product: borrowing subtracts the remainder from the two-limb number exactly.
rule subtractProduct(uint256 hi, uint256 lo, uint256 r) {
    require r <= hi * B() + lo;
    uint256 newHi;
    uint256 newLo;
    newHi, newLo = subtract(hi, lo, r);
    assert newHi * B() + newLo == hi * B() + lo - r;
}

// Check the final unchecked multiplication returns the low word of the exact product.
rule finalProductCorrect(uint256 lo, uint256 inv) {
    uint256 result = finalProduct(lo, inv);
    assert result == (lo * inv) % B();
}
