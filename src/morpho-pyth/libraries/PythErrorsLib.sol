// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Pyth Data Association
/// @notice Library exposing error messages emitted by MorphoPythOracle.
library PythErrorsLib {
    /// @notice Thrown when the answer returned by a Pyth feed is negative.
    string constant NEGATIVE_ANSWER = "PythPriceFeedLib: Negative answer";

    /// @notice Thrown when the vault conversion sample is 0.
    string constant VAULT_CONVERSION_SAMPLE_IS_ZERO = "PythPriceFeedLib: Vault conversion sample is zero";

    /// @notice Thrown when the vault conversion sample is not 1 while vault = address(0).
    string constant VAULT_CONVERSION_SAMPLE_IS_NOT_ONE = "PythPriceFeedLib: Vault conversion sample is not one";
}
