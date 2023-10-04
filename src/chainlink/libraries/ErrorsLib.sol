// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library ErrorsLib {
    /// @notice Thrown when the answer returned by a Chainlink feed is negative.
    string constant NEGATIVE_ANSWER = "negative answer";
}
