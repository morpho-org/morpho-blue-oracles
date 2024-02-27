// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IStEth} from "./interfaces/IStEth.sol";
import {MinimalAggregatorV3Interface} from "./interfaces/MinimalAggregatorV3Interface.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title WstEthEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/ETH exchange rate price feed.
/// @dev This contract should only be used as price feed for `ChainlinkOracle`.
contract WstEthEthExchangeRateChainlinkAdapter is MinimalAggregatorV3Interface {
    uint8 public constant decimals = 18;
    string public constant description = "wstETH/ETH exchange rate";

    IStEth public immutable ST_ETH;

    constructor(address stEth) {
        require(stEth != address(0), ErrorsLib.ZERO_ADDRESS);

        ST_ETH = IStEth(stEth);
    }

    /// @dev Silently overflows if `stEthPerToken` is greater than `type(int256).max`.
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        // It is assumed that `getPooledEthByShares` returns a price with 18 decimals precision.
        return (0, int256(ST_ETH.getPooledEthByShares(1 ether)), 0, 0, 0);
    }
}
