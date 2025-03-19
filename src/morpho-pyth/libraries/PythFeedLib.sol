// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

import {PythErrorsLib} from "./PythErrorsLib.sol";

/// @title PythFeedLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing functions to interact with a Pyth feed.
library PythFeedLib {

    /// @dev Returns the price of a `priceId`.
    /// @dev When `priceId` is the address zero, returns 1.
    function getPrice(IPyth pyth, bytes32 priceId, uint256 maxAge) internal view returns (uint256) {
        if (priceId == bytes32(0)) return 1;

        PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceId, maxAge);
        return uint256(int256(price.price));
    }
    /// @dev Returns the number of decimals of a `priceId`.
    /// @dev When `priceId` is the address zero, returns 0.
    function getDecimals(IPyth pyth, bytes32 priceId) internal view returns (uint256) {
        if (priceId == bytes32(0)) return 0;

        PythStructs.Price memory price = pyth.getPriceUnsafe(priceId);
        return uint256(-1 * int256(price.expo));
    }
}
