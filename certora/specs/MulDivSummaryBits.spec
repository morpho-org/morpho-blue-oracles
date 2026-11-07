// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

/// Powers of two

// Check extraction and flip with word-sized predicates and exact bitwise operations.
rule twosWord(uint256 d) {
    require d > 0, "The slow path has a positive denominator";

    uint256 odd;
    uint256 t;
    uint256 flipped;
    odd, t, flipped = twos(d);

    assert wordTwosPost(d, odd, t, flipped);
}

// Check that the real twos block supplies a zero or power-of-two flipped word.
rule twosPower(uint256 d) {
    require d > 0, "The slow path has a positive denominator";

    uint256 odd;
    uint256 t;
    uint256 flipped;
    odd, t, flipped = twos(d);

    assert flipped == 0 || (flipped & assert_uint256(flipped - 1)) == 0;
}

/// Seed

// Check the XOR seed at four-bit precision using exact bitwise operations.
rule seedWord(uint256 d) {
    require d % 2 == 1, "The inverse seed is used only for odd denominators";

    uint256 inv = seed(d);
    uint256 residue = seedProduct(d, inv);

    assert residue == 1;
}

/// Lemmas

// Check the generic OR identity for disjoint binary digits.
rule powerOr(uint256 a, uint256 b, uint256 p) {
    require p > 0 && (p & assert_uint256(p - 1)) == 0;
    require a < p && b % p == 0;

    assert (a | b) == a + b;
}
