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

// Check the generic Newton update with explicit word and precision witnesses.
rule newtonCorrect(uint256 d, uint256 inv, uint256 p) {
    require p >= 2 && B() % (p * p) == 0 && (d * inv) % p == 1, "assumption";

    uint256 next = newton(d, inv, p);
    mathint a = d * inv;
    mathint t = a % B();
    mathint aq = a / B();
    assert a == t + aq * B(), "hint";
    mathint s = (2 - t) % B();
    mathint sq = (2 - t - s) / B();
    assert 2 - t == s + sq * B(), "hint";
    assert next == (inv * s) % B(), "hint";
    mathint nq = (inv * s) / B();
    assert inv * s == next + nq * B(), "hint";
    assert 2 - a == s + (sq - aq) * B(), "hint";
    assert d * next == a * s - d * nq * B(), "hint";
    assert a * (2 - a) == a * s + a * (sq - aq) * B(), "hint";
    mathint wrap = d * nq + a * (sq - aq);
    assert d * next == a * (2 - a) - wrap * B(), "hint";
    mathint k = a / p;
    assert a == 1 + k * p, "hint";
    mathint e = k * p;
    assert (1 + e) * (1 - e) == 1 - e * e, "hint";
    assert e * e == k * k * p * p, "hint";
    assert a * (2 - a) == 1 - k * k * p * p, "hint";
    mathint m = p * p;
    mathint bq = B() / m;
    assert m > 1, "hint";
    assert B() == bq * m, "hint";
    mathint q = -k * k - wrap * bq;
    mathint x = d * next;
    assert x == 1 + q * m, "hint";
    mathint r = x % m;
    mathint rq = (x - r) / m;
    assert x == rq * m + r, "hint";
    assert 0 <= r && r < m, "hint";
    assert (q - rq) * m == r - 1, "hint";
    assert q - rq == 0, "hint";

    assert (d * next) % (p * p) == 1;
}

// Check the Newton update never reverts with zero message value.
rule newtonNeverReverts(env e, uint256 d, uint256 inv, uint256 p) {
    require e.msg.value == 0, "assumption";
    newton@withrevert(e, d, inv, p);
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
