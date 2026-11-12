// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

/// product

// Check productCorrect: the CRT block reconstructs both limbs of the exact product.
rule productCorrect(uint256 x, uint256 y) {
    uint256 hi;
    uint256 lo;
    hi, lo = product(x, y);

    assert hi == x * y / B() && lo == x * y % B();
}

// Check the product block never reverts with zero message value.
rule productNeverReverts(env e, uint256 x, uint256 y) {
    require e.msg.value == 0, "assume no msg.value";
    product@withrevert(e, x, y);
    assert !lastReverted;
}

/// subtract

// Check subtractCorrect: borrowing subtracts the remainder from the two-limb number exactly.
rule subtractCorrect(uint256 hi, uint256 lo, uint256 r) {
    uint256 newHi;
    uint256 newLo;
    newHi, newLo = subtract(hi, lo, r);

    assert r <= hi * B() + lo => newHi * B() + newLo == hi * B() + lo - r;
}

// Check the subtraction block never reverts with zero message value.
rule subtractNeverReverts(env e, uint256 hi, uint256 lo, uint256 r) {
    require e.msg.value == 0, "assume no msg.value";
    subtract@withrevert(e, hi, lo, r);
    assert !lastReverted;
}

/// twos

// Check the powers-of-two block never reverts with zero message value.
rule twosNeverReverts(env e, uint256 d) {
    require e.msg.value == 0, "assume no msg.value";
    twos@withrevert(e, d);
    assert !lastReverted;
}

/// shift

// Check the real shift block using disjoint digits and explicit division witnesses.
rule shiftWord(uint256 hi, uint256 lo, uint256 t, uint256 flipped) {
    require wordShiftPre(t, flipped), "assumption";
    require flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0, "assumption";

    require flipped > 0 && (flipped & assert_uint256(flipped - 1)) == 0 && assert_uint256(lo / t) < flipped && assert_uint256((hi * flipped) % B()) % flipped == 0 => (assert_uint256(lo / t) | assert_uint256((hi * flipped) % B())) == assert_uint256(lo / t) + assert_uint256((hi * flipped) % B()), "BitsLemmas.shiftDisjointOr(lo/t, (hi * flipped) % B, flipped)";

    uint256 high = finalProduct(hi, flipped);
    uint256 result = shift(hi, lo, t, flipped);

    assert high == (hi * flipped) % B(), "hint";
    assert result == (assert_uint256(lo / t) | high), "hint";
    mathint u = max_uint256 / t + 1;
    assert B() == u * t, "hint";
    assert lo / t < u, "hint";
    mathint q = hi / t;
    mathint r = hi % t;
    assert hi == q * t + r, "hint";
    assert hi * u == q * B() + r * u, "hint";
    assert r * u < B(), "hint";
    assert (hi * u) % B() == r * u, "hint";
    if (t == 1) {
        assert flipped == 0, "hint";
        assert high == 0, "hint";
        assert result == lo, "hint";
    } else {
        assert flipped == u, "hint";
        assert high == r * u, "hint";
        assert high % flipped == 0, "hint";
    }
    assert lo / t + high < B(), "hint";

    assert result == lo / t + high;
}

// Check shift reconstruction and no-wrap arithmetic without bitwise operations or axioms.
rule shiftArithmetic(uint256 hi, uint256 lo, uint256 t, uint256 flipped) {
    require wordShiftPre(t, flipped), "assumption";

    mathint u = max_uint256 / t + 1;
    assert B() == u * t, "hint";
    assert u == B() / t, "hint";
    assert lo / t < u, "hint";
    mathint q = hi / t;
    mathint r = hi % t;
    assert hi == q * t + r, "hint";
    assert hi * u == q * B() + r * u, "hint";
    assert r * u < B(), "hint";
    assert (hi * u) % B() == r * u, "hint";
    if (t == 1) {
        assert flipped == 0, "hint";
        assert (hi * flipped) % B() == r * u, "hint";
    } else {
        assert flipped == u, "hint";
        assert max_uint256 % flipped == flipped - 1, "hint";
        assert (hi * flipped) % B() == r * u, "hint";
    }
    assert ((hi * flipped) % B()) % u == 0, "hint";
    assert lo / t + (hi * flipped) % B() < B(), "hint";
    mathint lowQ = lo / t;
    mathint lowR = lo % t;
    assert lo == lowQ * t + lowR, "hint";
    assert hi * B() + lo == (hi * u + lowQ) * t + lowR, "hint";
    assert (hi * B() + lo) / t == hi * u + lowQ, "hint";
    assert (hi * u + lowQ) % B() == r * u + lowQ, "hint";

    assert lo / t + (hi * flipped) % B() == ((hi * B() + lo) / t) % B();
}

// Check the shift block never reverts with zero message value.
rule shiftNeverReverts(env e, uint256 hi, uint256 lo, uint256 t, uint256 flipped) {
    require e.msg.value == 0, "assume no msg.value";
    shift@withrevert(e, hi, lo, t, flipped);
    assert !lastReverted;
}

/// seed

// Check the inverse seed never reverts with zero message value.
rule seedNeverReverts(env e, uint256 d) {
    require e.msg.value == 0, "assume no msg.value";
    seed@withrevert(e, d);
    assert !lastReverted;
}

/// newton

// Check Newton precision doubling from 4 to 8 bits with explicit error and wrap witnesses.
rule newton4(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 4) == 1, "The preceding iteration supplies the current inverse precision";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert (expression - next) % B() == 0, "hint";
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B(), "hint";
    mathint error = (d * inv - 1) / (2 ^ 4);
    assert d * inv == 1 + (2 ^ 4) * error, "hint";
    assert d * expression == 1 - (2 ^ 8) * error * error, "hint";

    assert (d * next) % (2 ^ 8) == 1;
}

// Check Newton precision doubling from 8 to 16 bits with explicit error and wrap witnesses.
rule newton8(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 8) == 1, "The preceding iteration supplies the current inverse precision";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert (expression - next) % B() == 0, "hint";
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B(), "hint";
    mathint error = (d * inv - 1) / (2 ^ 8);
    assert d * inv == 1 + (2 ^ 8) * error, "hint";
    assert d * expression == (d * inv) * (2 - d * inv), "hint";
    assert d * expression == 1 - (2 ^ 16) * error * error, "hint";
    mathint productQ = -error * error - d * wrap * (2 ^ 240);
    assert d * next == 1 + (2 ^ 16) * productQ, "hint";

    assert (d * next) % (2 ^ 16) == 1;
}

// Check Newton precision doubling from 16 to 32 bits with explicit error and wrap witnesses.
rule newton16(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 16) == 1, "The preceding iteration supplies the current inverse precision";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert (expression - next) % B() == 0, "hint";
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B(), "hint";
    mathint error = (d * inv - 1) / (2 ^ 16);
    assert d * inv == 1 + (2 ^ 16) * error, "hint";
    assert d * expression == 1 - (2 ^ 32) * error * error, "hint";

    assert (d * next) % (2 ^ 32) == 1;
}

// Check Newton precision doubling from 32 to 64 bits with explicit error and wrap witnesses.
rule newton32(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 32) == 1, "The preceding iteration supplies the current inverse precision";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert (expression - next) % B() == 0, "hint";
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B(), "hint";
    mathint error = (d * inv - 1) / (2 ^ 32);
    assert d * inv == 1 + (2 ^ 32) * error, "hint";
    assert d * expression == 1 - (2 ^ 64) * error * error, "hint";

    assert (d * next) % (2 ^ 64) == 1;
}

// Check Newton precision doubling from 64 to 128 bits with explicit error and wrap witnesses.
rule newton64(uint256 d, uint256 inv) {
    require d % 2 == 1 && (d * inv) % (2 ^ 64) == 1, "The preceding iteration supplies the current inverse precision";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert (expression - next) % B() == 0, "hint";
    mathint wrap = (expression - next) / B();
    assert expression == next + wrap * B(), "hint";
    mathint error = (d * inv - 1) / (2 ^ 64);
    assert d * inv == 1 + (2 ^ 64) * error, "hint";
    assert d * expression == 1 - (2 ^ 128) * error * error, "hint";

    assert (d * next) % (2 ^ 128) == 1;
}

// Check Newton precision doubling from 128 to 256 bits by squaring the divisible error.
rule newton128(uint256 d, uint256 inv) {
    mathint error = d * inv - 1;
    require d % 2 == 1 && (d * inv) % (2 ^ 128) == 1, "The preceding iteration supplies the current inverse precision";
    require 2 ^ 128 > 0 && error % (2 ^ 128) == 0 && error % (2 ^ 128) == 0 => (error * error) % ((2 ^ 128) * (2 ^ 128)) == 0, "MulDivLemmas.newtonDivisibility(error, error, 2^128)";

    uint256 next = newton(d, inv);

    mathint expression = inv * (2 - d * inv);
    newtonModularPolynomialLemma(inv, 2, d * inv);
    assert next == expression % B(), "hint";
    assert error % (2 ^ 128) == 0, "hint";
    mathint errorQ = error / (2 ^ 128);
    assert error == (2 ^ 128) * errorQ, "hint";
    assert error * error == B() * errorQ * errorQ, "hint";
    assert (error * error) % B() == 0, "hint";
    assert d * expression == 1 - error * error, "hint";
    assert (d * expression) % B() == 1, "hint";
    newtonModularPolynomialLemma(d, expression, 0);

    assert (d * next) % B() == 1;
}

function newtonModularPolynomialLemma(mathint a, mathint b, mathint c) {
    require (a * (b - c)) % B() == ((a % B()) * ((b - (c % B())) % B())) % B(), "MulDivLemmas.newtonModularPolynomial";
}

// Check modular normalization for the word modulus using integer division witnesses.
rule newtonModularPolynomial(mathint a, mathint b, mathint c) {
    mathint ar = a % B();
    mathint aq = (a - ar) / B();
    assert a == aq * B() + ar, "hint";
    mathint cr = c % B();
    mathint cq = (c - cr) / B();
    assert c == cq * B() + cr, "hint";
    mathint u = b - cr;
    mathint ur = u % B();
    mathint uq = (u - ur) / B();
    assert u == uq * B() + ur, "hint";
    assert b - c == ur + (uq - cq) * B(), "hint";
    mathint p = ar * ur;
    mathint pr = p % B();
    mathint pq = (p - pr) / B();
    assert p == pq * B() + pr, "hint";
    mathint k = pq + aq * (b - c) + ar * (uq - cq);
    assert a * (b - c) == pr + B() * k, "hint";
    assert 0 <= pr && pr < B(), "hint";
    assert (a * (b - c)) % B() == pr, "hint";

    assert (a * (b - c)) % B() == ((a % B()) * ((b - (c % B())) % B())) % B();
}

// Check that multiplying two multiples of m produces a multiple of m squared.
rule newtonDivisibility(mathint a, mathint b, mathint m) {
    if (m > 0 && a % m == 0 && b % m == 0) {
        mathint aq = a / m;
        mathint bq = b / m;
        assert a == m * aq, "hint";
        assert b == m * bq, "hint";
        assert a * b == (m * m) * (aq * bq), "hint";
        assert (a * b) % (m * m) == 0, "hint";
    }

    assert m > 0 && a % m == 0 && b % m == 0 => (a * b) % (m * m) == 0;
}

// Check the Newton update never reverts with zero message value.
rule newtonNeverReverts(env e, uint256 d, uint256 inv) {
    require e.msg.value == 0, "assume no msg.value";
    newton@withrevert(e, d, inv);
    assert !lastReverted;
}

/// finalProduct

// Check the final unchecked multiplication returns the low word of the exact product.
rule finalProductCorrect(uint256 lo, uint256 inv) {
    uint256 result = finalProduct(lo, inv);

    assert result == (lo * inv) % B();
}

// Check inverse cancellation for the word modulus using integer division witnesses.
rule finalProductCancelInverse(mathint d, mathint q, mathint inv) {
    require d >= 0 && q >= 0 && inv >= 0, "assumption";
    require (d * inv) % B() == 1, "assumption";

    mathint k = (d * inv - 1) / B();
    assert d * inv == 1 + k * B(), "hint";
    mathint p = (d * q) % B();
    mathint w = (d * q - p) / B();
    assert d * q == p + w * B(), "hint";
    mathint qr = q % B();
    mathint qw = (q - qr) / B();
    assert q == qr + qw * B(), "hint";
    assert p * inv == q + B() * (q * k - w * inv), "hint";
    assert p * inv == qr + B() * (qw + q * k - w * inv), "hint";

    assert (((d * q) % B()) * inv) % B() == q % B();
}

// Check the final product never reverts with zero message value.
rule finalProductNeverReverts(env e, uint256 lo, uint256 inv) {
    require e.msg.value == 0, "assume no msg.value";
    finalProduct@withrevert(e, lo, inv);
    assert !lastReverted;
}
