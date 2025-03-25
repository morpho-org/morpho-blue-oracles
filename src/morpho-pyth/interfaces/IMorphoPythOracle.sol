// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IERC4626} from "../../interfaces/IERC4626.sol";
import {IOracle} from "../../../lib/morpho-blue/src/interfaces/IOracle.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

/// @title IMorphoPythOracle
/// @author Pyth Data Association
/// @notice Interface of MorphoPythOracle.
/// @dev This interface is used to interact with the MorphoPythOracle contract.
/// @dev Fetch price feed ids from https://www.pyth.network/developers/price-feed-ids
interface IMorphoPythOracle is IOracle {
    /// @notice Returns the address of the Pyth contract deployed on the chain.
    function pyth() external view returns (IPyth);

    /// @notice Returns the address of the base ERC4626 vault.
    function BASE_VAULT() external view returns (IERC4626);

    /// @notice Returns the base vault conversion sample.
    function BASE_VAULT_CONVERSION_SAMPLE() external view returns (uint256);

    /// @notice Returns the address of the quote ERC4626 vault.
    function QUOTE_VAULT() external view returns (IERC4626);

    /// @notice Returns the quote vault conversion sample.
    function QUOTE_VAULT_CONVERSION_SAMPLE() external view returns (uint256);

    /// @notice Returns the price feed id of the first base feed.
    function BASE_FEED_1() external view returns (bytes32);

    /// @notice Returns the price feed id of the second base feed.
    function BASE_FEED_2() external view returns (bytes32);

    /// @notice Returns the price feed id of the first quote feed.
    function QUOTE_FEED_1() external view returns (bytes32);

    /// @notice Returns the price feed id of the second quote feed.
    function QUOTE_FEED_2() external view returns (bytes32);

    /// @notice Returns the price scale factor, calculated at contract creation.
    function SCALE_FACTOR() external view returns (uint256);

    /// @notice Returns the maximum age for the oracles prices to be considered valid.
    function PRICE_FEED_MAX_AGE() external view returns (uint256);
}
