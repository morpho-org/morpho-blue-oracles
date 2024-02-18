// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @notice Thrown when the answer returned by a Chainlink feed is negative.
    string constant NEGATIVE_ANSWER = "negative answer";

    /// @notice Thrown when the vault conversion sample is 0.
    string constant VAULT_CONVERSION_SAMPLE_IS_ZERO = "vault conversion sample is zero";

    /// @notice Thrown when the vault conversion sample is not 1 while vault = address(0).
    string constant VAULT_CONVERSION_SAMPLE_IS_NOT_ONE = "vault conversion sample is not one";
}
