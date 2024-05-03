// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @notice Thrown when the weETH redemption price grows at a faster rate
    /// than what is tolerable
    string constant GROWTH_RATE_TOO_HIGH = "converstion rate growth too high";

    string constant SNAPSHOT_TOO_SOON = "snapshot too soon";

    string constant SNAPSHOT_MAY_OVERFLOW_SOON = "snapshot ratio may overflow soon";

    string constant INVALID_SNAPSHOT_RATIO = "invalid snapshot ratio";
}
