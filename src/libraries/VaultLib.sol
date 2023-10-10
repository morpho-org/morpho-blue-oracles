// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC4626} from "../interfaces/IERC4626.sol";

/// @title ChainlinkDataFeedLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing functions to price shares of an ERC4626 vault.
library VaultLib {
    /// @dev Converts `shares` into the corresponding assets on the `vault`.
    /// @dev When `vault` is the address zero, returns 1.
    function getAssets(IERC4626 vault, uint256 shares) internal view returns (uint256) {
        if (address(vault) == address(0)) return 1;

        return vault.convertToAssets(shares);
    }

    /// @dev Returns the number of decimals of a `vault`, seen as an ERC20.
    /// @dev When `vault` is the address zero, returns 0.
    function getDecimals(IERC4626 vault) internal view returns (uint256) {
        if (address(vault) == address(0)) return 0;

        return vault.decimals();
    }
}
