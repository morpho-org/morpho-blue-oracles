// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IERC4626} from "./IERC4626.sol";
import {IOracle} from "../../lib/morpho-blue/src/interfaces/IOracle.sol";
import {MinimalAggregatorV3Interface} from "./MinimalAggregatorV3Interface.sol";

/// @title IChainlinkOracle
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Interface of ChainlinkOracle.
interface IChainlinkOracle is IOracle {
    /// @notice Returns the address of the ERC4626 vault.
    function VAULT() external view returns (IERC4626);

    /// @notice Returns the vault conversion sample.
    function VAULT_CONVERSION_SAMPLE() external view returns (uint256);

    /// @notice Returns the address of the first Chainlink base feed.
    function BASE_FEED_1() external view returns (MinimalAggregatorV3Interface);

    /// @notice Returns the address of the second Chainlink base feed.
    function BASE_FEED_2() external view returns (MinimalAggregatorV3Interface);

    /// @notice Returns the address of the first Chainlink quote feed.
    function QUOTE_FEED_1() external view returns (MinimalAggregatorV3Interface);

    /// @notice Returns the address of the second Chainlink quote feed.
    function QUOTE_FEED_2() external view returns (MinimalAggregatorV3Interface);

    /// @notice Returns the price scale factor, calculated at contract creation.
    function SCALE_FACTOR() external view returns (uint256);
}
