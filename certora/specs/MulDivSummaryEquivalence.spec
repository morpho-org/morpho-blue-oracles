// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

import "../helpers/MulDiv.spec";

// Check that the split implementation has the same revert and return behavior without summaries.
rule stepsEquivalent(uint256 x, uint256 y, uint256 d) {
    uint256 actual = mulDiv@withrevert(x, y, d);
    bool actualReverted = lastReverted;
    uint256 split = mulDivSteps@withrevert(x, y, d);
    bool splitReverted = lastReverted;

    assert actualReverted == splitReverted;
    assert !actualReverted && !splitReverted => actual == split;
}
