// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IFxUSD} from "./interfaces/IFxUSD.sol";
import {MinimalAggregatorV3Interface} from "./interfaces/MinimalAggregatorV3Interface.sol";

/// @title FxUSDNetAssetValueChainlinkAdapter
/// @author Aladdin DAO
/// @custom:contact security@morpho.org
/// @notice fxUSD net asset value price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract FxUSDNetAssetValueChainlinkAdapter is MinimalAggregatorV3Interface {
    /// @inheritdoc MinimalAggregatorV3Interface
    // @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "fxUSD net asset value";

    /// @notice The address of fxUSD on Ethereum.
    IFxUSD public immutable fxUSD;

    constructor(IFxUSD _fxUSD) {
        fxUSD = _fxUSD;
    }

    /// @inheritdoc MinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `nav`'s return value is greater than `type(int256).max`.
    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        // It is assumed that `fxUSD.nav()` returns a price with 18 decimals precision.
        return (0, int256(fxUSD.nav()), 0, 0, 0);
    }
}
