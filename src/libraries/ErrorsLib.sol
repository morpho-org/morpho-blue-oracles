// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @notice Thrown when the answer returned by a Chainlink feed is negative.
    string constant NEGATIVE_ANSWER = "negative answer";
    /// @notice Thrown when passing an inconsistent sample amount.
    string constant INCONSISTENT_SAMPLE_AMOUNT = "inconsistent sample amount";
}
